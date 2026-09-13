# open-abap-apc

ABAP Push Channels where there is no system. A handler written for SAP APC
(`cl_apc_wsp_ext_stateful_base`, `if_apc_wsp_extension`) runs unchanged; the
ICF is replaced by a host that anyone can drive: a websocket server in Node,
a page that calls it directly, a worker, or a test.

    lo_host = NEW zcl_apc_host( iv_handler = 'ZCL_APC_DEMO_HANDLER' ).
    lo_host->open( ).                  " on_accept, on_start
    lo_host->message( 'frame' ).       " on_message
    lt_frames = lo_host->drain( ).     " what the handler pushed

`src/apc` is the SAP-named part: the five-method `if_apc_wsp_extension`
(open-abap-core has two), `set_text` on `if_apc_wsp_message`, and the
stateless and stateful base classes. It is meant as a pull request to
open-abap-core; until then this project ships it and leaves core's
`src/tcp` out of its dependency, so nothing collides.

`src/host` is the runtime: message, message manager (it collects what the
handler sends), binding manager, initial request, context, host.

`src/demo` is a handler that answers `frame` with a plasma, to have
something to run.

## Numbers

`npm run bench` on 2026-09-13, Node 26, a 64x40 character plasma, three
sines per cell:

    200 frames: 1.8 ms per frame, 560 frames per second

That is about 0.7 microseconds per cell. A vector frame of the kind
oisee/vivid-vibes sends (lines, texts, triangles, rects, circles, a few
hundred to a few thousand primitives) should cost the same order, well
inside the 40 ms of 25 frames per second; a per-pixel effect at 640x400
would not, it is a hundred times more cells.

## In a page, with no server

`web/apc-socket.mjs` puts a WebSocket-shaped object in front of the host, so
a page written for APC talks to a handler that is in the page:

    import {install} from "./web/apc-socket.mjs";
    install({handler: "ZCL_O4D_APC_HANDLER"});
    // the page's own `new WebSocket("ws://host/sap/bc/apc/sap/x")` now
    // reaches that handler, and its frames arrive as messages

Nothing is framed and no network is touched; it is the trick
express-icf-shim plays for ICF, one layer up. A url that is not an APC one is
handed back to the real WebSocket, so a page that also talks to something
real keeps it. `npm run test:web` checks the seam against the plasma handler:
a config frame on connect, a frame per request, and an unknown handler that
fails the socket rather than the process.

Measured with oisee/vivid-vibes' own handler behind it: five frame requests,
six messages back, 2994 bytes, and the first message is that demo's config.

## In an engine that is not V8

`probe/` runs the same transpiled ABAP in goja, the pure-Go engine, for the
question "can steamgate be embedded in one Go binary with no cgo". webpack
makes one classic script (top level await on, a single chunk, the library
export is a promise), Babel lowers the async generators
(`@babel/plugin-transform-async-generator-functions`), and `probe/goja` runs
it with an event loop.

Raw, goja refuses the bundle: `Unexpected token await`, 14035 errors, because
`abap.statements.loop` is an async generator and every LOOP AT consumes it.
Lowered, it loads in 0.2 s and answers exactly as Node does. Three shims are
needed and no more (`probe/shim.js`): `Intl.DateTimeFormat`, Node's `Buffer`,
and `WeakRef`.

Measured 2026-09-13, goja v0.0.0-20260911104922, Node 26:

| what | Node | goja |
|---|---|---|
| a Gateway read: 1000 rows, filter, map, 13 KB of JSON | 1.95 ms | 36 ms |
| the same over 100 rows, 20 out | 0.8 ms | 7.5 ms |
| a frame of the 64x40 plasma | 4 ms | 174 ms |

So twenty to forty times slower, in absolute terms tens of milliseconds for a
request shaped like an OData read: usable for a service, not for a demo at 25
frames a second.

## Running

    npm run lint      abaplint, 0 issues
    npm run unit      transpile and run the ABAP unit tests
    npm run bench     frames per second

`node_modules` and `deps` are symbolic links into the neighbouring
open-steamgate checkout, so this project needs no install of its own.
