// One classic script out of the transpiled ESM tree, for an engine that has
// no modules: webpack resolves the 568 files and the top-level await of
// init.mjs into its own async-module machinery. The entry exposes what a
// host needs on globalThis.APC.
import webpack from "webpack";
import {fileURLToPath} from "node:url";
import {dirname, resolve} from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));

webpack({
  mode: "production",
  target: ["web", "es2020"],
  entry: resolve(root, "probe/entry.mjs"),
  experiments: {topLevelAwait: true},
  // init.mjs imports its 561 objects dynamically, and every dynamic import
  // is a chunk: an engine with no loader needs them all in the one file
  optimization: {minimize: process.env.MIN === "1", splitChunks: false, runtimeChunk: false},
  plugins: [new webpack.optimize.LimitChunkCountPlugin({maxChunks: 1})],
  performance: {hints: false},
  output: {
    path: resolve(root, "probe/build"),
    filename: "bundle.js",
    library: {name: "APC", type: "var"},
    iife: true,
  },
  // an engine that is neither Node nor a browser: the Node built-ins the
  // kernel classes reach for become empty modules, and the embedder shims
  // whatever a used code path really needs (Buffer, above all)
  resolve: {
    fullySpecified: false,
    fallback: {path: false, fs: false, crypto: false, os: false, util: false, stream: false, http: false, https: false, zlib: false, net: false, tls: false, url: false, child_process: false, worker_threads: false, buffer: false},
  },
}, (error, stats) => {
  if (error) {
    console.error(error);
    process.exit(1);
  }
  const info = stats.toJson({errors: true, warnings: true, assets: true});
  for (const e of info.errors ?? []) {
    console.error(e.message);
  }
  console.log(`bundle.js: ${(info.assets[0].size / 1024).toFixed(0)} KB, ${info.modules.length} modules, ${(info.time / 1000).toFixed(1)} s`);
  process.exit((info.errors ?? []).length > 0 ? 1 : 0);
});
