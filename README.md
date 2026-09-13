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

## Running

    npm run lint      abaplint, 0 issues
    npm run unit      transpile and run the ABAP unit tests
    npm run bench     frames per second

`node_modules` and `deps` are symbolic links into the neighbouring
open-steamgate checkout, so this project needs no install of its own.
