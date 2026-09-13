// The shim, against this project's own handler, so the test needs nothing
// but a transpile: node web/apc-socket.test.mjs
//
// What it proves is the seam rather than the plasma: a page that opens a
// WebSocket reaches an ABAP handler in the same process, gets what the
// handler pushed, in order, and sees a close it can act on.
import {strict as assert} from "node:assert";
import {existsSync} from "node:fs";
import {dirname, join} from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const init = join(root, "output", "init.mjs");
if (existsSync(init) === false) {
  console.error("there is no output/ yet: run npm run unit or npx abap_transpile first");
  process.exit(2);
}

const {initializeABAP} = await import(pathToFileURL(init).href);
await initializeABAP();
const {ApcSocket, install} = await import("./apc-socket.mjs");

const settle = () => new Promise((resolve) => setTimeout(resolve, 50));
let failures = 0;
const it = async (what, run) => {
  try {
    await run();
    console.log(`ok   ${what}`);
  } catch (error) {
    failures += 1;
    console.log(`FAIL ${what}\n     ${error.message}`);
  }
};

await it("a page's WebSocket reaches the handler and gets its frames", async () => {
  const restore = install({handler: "ZCL_APC_DEMO_HANDLER"});
  try {
    const ws = new WebSocket("ws://localhost/sap/bc/apc/sap/demo");
    const frames = [];
    let opened = false;
    ws.addEventListener("open", () => {
      opened = true;
    });
    ws.onmessage = (event) => frames.push(event.data);

    await settle();
    assert.equal(opened, true, "the socket never opened");
    assert.equal(ws.readyState, ApcSocket.OPEN);

    ws.send("frame");
    ws.send("frame");
    await settle();
    // the handler answers a connection with a config frame and then one
    // frame per request, so three messages for two requests
    assert.ok(frames.length >= 3, `expected a config and two frames, got ${frames.length}`);
    assert.ok(frames[0].includes('"type":"config"'), `the first message is not the config: ${frames[0].slice(0, 60)}`);
    assert.ok(frames.slice(1).every((f) => f.length > 1000), `a frame that short is not a plasma: ${frames.slice(1).map((f) => f.length).join(", ")}`);

    ws.close();
    await settle();
    assert.equal(ws.readyState, ApcSocket.CLOSED);
  } finally {
    restore();
  }
});

await it("a url that is not APC is left to the real WebSocket", async () => {
  class Real {
    constructor(url) {
      this.url = url;
      this.mine = true;
    }
  }
  const target = {WebSocket: Real};
  const restore = install({target, handler: "ZCL_APC_DEMO_HANDLER"});
  try {
    const other = new target.WebSocket("wss://example.invalid/socket");
    assert.equal(other.mine, true, "a foreign url was taken over");
    const ours = new target.WebSocket("ws://localhost/sap/bc/apc/sap/demo");
    assert.equal(ours.mine, undefined, "an APC url was not taken over");
    ours.close();
  } finally {
    restore();
  }
  assert.equal(target.WebSocket, Real, "the original was not put back");
});

await it("an unknown handler fails the socket rather than the process", async () => {
  const ws = new ApcSocket("ws://localhost/sap/bc/apc/sap/nope", {handler: "ZCL_DOES_NOT_EXIST"});
  const seen = [];
  ws.onerror = (event) => seen.push(`error: ${event.message}`);
  ws.onclose = (event) => seen.push(`close: ${event.code}`);
  await settle();
  assert.equal(ws.readyState, ApcSocket.CLOSED);
  assert.ok(seen.some((s) => s.startsWith("error")), `no error was reported: ${seen.join(", ")}`);
  assert.ok(seen.some((s) => s === "close: 1011"), `no unclean close: ${seen.join(", ")}`);
});

console.log(failures === 0 ? "\nall good" : `\n${failures} failing`);
process.exit(failures === 0 ? 0 : 1);
