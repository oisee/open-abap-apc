// the same bundle a foreign engine would get, run in Node first
import {readFileSync} from "node:fs";
import {dirname, resolve} from "node:path";
import {fileURLToPath} from "node:url";

const file = process.argv[2] ?? "build/bundle.js";
const source = readFileSync(resolve(dirname(fileURLToPath(import.meta.url)), file), "utf8");
// an entry that awaits at module scope makes webpack export a promise
const APC = await (0, eval)(source + "; APC");
console.log(await APC.boot());
console.log("probe:", await APC.probe());
console.log("frames:", await APC.frames(Number(process.argv[3] ?? 100)));
if (process.argv[4]) {
  console.log("odata:", await APC.odata(Number(process.argv[4]), Number(process.argv[5] ?? 1000), Number(process.argv[6] ?? 100)));
}
