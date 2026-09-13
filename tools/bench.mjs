// How fast is a frame, when the effect is ABAP and the runtime is a browser
// engine? The host is driven the way a page would drive it: open, then one
// "frame" message per frame, reading back what the handler pushed.
import {initializeABAP} from "../output/init.mjs";
import {zcl_apc_host} from "../output/zcl_apc_host.clas.mjs";

const FRAMES = Number(process.argv[2] ?? 200);

await initializeABAP();

const host = await (new zcl_apc_host()).constructor_({iv_handler: new abap.types.String().set("ZCL_APC_DEMO_HANDLER")});
await host.open();
const config = await host.drain();
console.log("config:", config.array()[0].get().slice(0, 120));

// one frame first, to see the shape and to leave the warm-up out of the number
await host.message({iv_text: new abap.types.String().set("frame")});
const first = (await host.drain()).array()[0].get();
const rows = JSON.parse(first).rows;
console.log(`frame: ${rows.length} rows of ${rows[0].length} characters, ${first.length} bytes of JSON`);
console.log(rows.slice(0, 6).join("\n"));

const started = performance.now();
for (let i = 0; i < FRAMES; i++) {
  await host.message({iv_text: new abap.types.String().set("frame")});
  await host.drain();
}
const ms = (performance.now() - started) / FRAMES;
console.log(`\n${FRAMES} frames: ${ms.toFixed(1)} ms per frame, ${(1000 / ms).toFixed(1)} frames per second`);
console.log(`the same at 640x400 would be about ${(ms * (640 * 400) / (64 * 40)).toFixed(0)} ms per frame`);
