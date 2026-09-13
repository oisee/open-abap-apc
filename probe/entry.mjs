// what the embedder calls: boot the runtime, then the two probes
import {initializeABAP} from "../output/init.mjs";
import {zcl_apc_probe} from "../output/zcl_apc_probe.clas.mjs";
import {zcl_apc_host} from "../output/zcl_apc_host.clas.mjs";
import {zcl_apc_odata_probe} from "../output/zcl_apc_odata_probe.clas.mjs";

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

// the shape of a Gateway read, database stubbed: filter, map, serialise
export async function odata(requests, rows, top) {
  const table = await zcl_apc_odata_probe.rows({iv_rows: new abap.types.Integer().set(rows)});
  const ranges = await zcl_apc_odata_probe.status_range({iv_status: new abap.types.Character(1).set("A")});

  const started = Date.now();
  let bytes = 0;
  for (let i = 0; i < requests; i++) {
    const json = await zcl_apc_odata_probe.get_entityset({
      it_rows: table, it_status: ranges, iv_top: new abap.types.Integer().set(top),
    });
    bytes = json.get().length;
  }
  const ms = Date.now() - started;
  return JSON.stringify({requests, rows, top, ms, msPerRequest: +(ms / requests).toFixed(2), bytes});
}
