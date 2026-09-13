// what the embedder calls: boot the runtime, then the two probes
import {initializeABAP} from "../output/init.mjs";
import {zcl_apc_probe} from "../output/zcl_apc_probe.clas.mjs";
import {zcl_apc_host} from "../output/zcl_apc_host.clas.mjs";

export async function boot() {
  await initializeABAP();
  return "booted";
}

// LOOP AT, string templates, packed arithmetic: one deterministic string
export async function probe() {
  return (await zcl_apc_probe.run()).get();
}

// the APC handler: open a connection and render frames
export async function frames(count) {
  const host = await (new zcl_apc_host()).constructor_({iv_handler: new abap.types.String().set("ZCL_APC_DEMO_HANDLER")});
  await host.open();
  await host.drain();
  const started = Date.now();
  let last = "";
  for (let i = 0; i < count; i++) {
    await host.message({iv_text: new abap.types.String().set("frame")});
    const sent = await host.drain();
    last = sent.array()[0].get();
  }
  return JSON.stringify({ms: Date.now() - started, frames: count, bytes: last.length});
}
