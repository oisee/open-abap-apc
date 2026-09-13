// Does transpiled ABAP run in goja once the async generators are lowered?
// The bundle is the one webpack made of open-abap-apc, put through
// @babel/plugin-transform-async-generator-functions. goja has no module
// loader and no event loop of its own, so the bundle arrives as one classic
// script and goja_nodejs/eventloop pumps the promise jobs.
package main

import (
	"fmt"
	"os"
	"time"

	"github.com/dop251/goja"
	"github.com/dop251/goja_nodejs/console"
	"github.com/dop251/goja_nodejs/eventloop"
	"github.com/dop251/goja_nodejs/require"
)

const driver = `
(function () {
  globalThis.__out = null;
  globalThis.__err = null;
  Promise.resolve(APC).then(async function (m) {
    var booted = await m.boot();
    var probe = await m.probe();
    var frames = await m.frames(FRAMES);
    globalThis.__out = JSON.stringify({booted: booted, probe: probe, frames: JSON.parse(frames)});
  }).catch(function (e) {
    globalThis.__err = String((e && e.stack) || e);
  });
})();
`

func main() {
	if len(os.Args) < 2 {
		fmt.Println("usage: probe <bundle.js> [frames]")
		os.Exit(2)
	}
	source, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Println("read:", err)
		os.Exit(1)
	}
	frames := "100"
	if len(os.Args) > 2 {
		frames = os.Args[2]
	}

	registry := new(require.Registry)
	loop := eventloop.NewEventLoop()
	var runtime *goja.Runtime
	var loadErr error
	loadMs := int64(0)

	loop.Run(func(vm *goja.Runtime) {
		runtime = vm
		registry.Enable(vm)
		console.Enable(vm)

		if shim, err := os.ReadFile("../shim.js"); err == nil {
			if _, err := vm.RunString(string(shim)); err != nil {
				loadErr = fmt.Errorf("the shim: %w", err)
				return
			}
		}

		started := time.Now()
		if _, err := vm.RunString(string(source)); err != nil {
			loadErr = fmt.Errorf("loading the bundle: %w", err)
			return
		}
		loadMs = time.Since(started).Milliseconds()

		if _, err := vm.RunString(replaceFrames(driver, frames)); err != nil {
			loadErr = fmt.Errorf("driving it: %w", err)
			return
		}
	})

	if loadErr != nil {
		fmt.Println("FAILED:", loadErr)
		os.Exit(1)
	}
	if v := runtime.Get("__err"); v != nil && !goja.IsNull(v) && !goja.IsUndefined(v) {
		fmt.Println("FAILED in JavaScript:", v.String())
		os.Exit(1)
	}
	out := runtime.Get("__out")
	if out == nil || goja.IsNull(out) || goja.IsUndefined(out) {
		fmt.Println("FAILED: the promise never settled")
		os.Exit(1)
	}
	fmt.Printf("bundle loaded in %d ms\n%s\n", loadMs, out.String())
}

func replaceFrames(s, frames string) string {
	out := ""
	for i := 0; i < len(s); i++ {
		if i+6 <= len(s) && s[i:i+6] == "FRAMES" {
			out += frames
			i += 5
			continue
		}
		out += string(s[i])
	}
	return out
}
