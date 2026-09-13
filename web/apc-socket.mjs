// A websocket with no server behind it.
//
// A page written for APC opens `ws://host/sap/bc/apc/sap/<application>` and
// talks to a handler on a system. In a bundle there is no system and no
// socket: the handler is in the page, transpiled, and zcl_apc_host drives
// it. So this puts a WebSocket-shaped object in front of the host, and the
// page does not know the difference.
//
// What it is not: a websocket implementation. Nothing is framed, nothing is
// masked, no network is touched. It is the same trick express-icf-shim plays
// for ICF, one layer up: keep the shape the caller expects and answer it
// from ABAP that is already here.
//
// Usage, after the transpiled runtime is loaded:
//
//   import {install} from "./apc-socket.mjs";
//   install({handler: "ZCL_O4D_APC_HANDLER"});
//   // the page's own `new WebSocket(...)` now reaches that handler
//
// The page's frames arrive as messages in the order the handler pushed
// them, which is what drain( ) gives back, because a host that is not the
// ICM has nowhere to push to as it goes.

const CONNECTING = 0;
const OPEN = 1;
const CLOSING = 2;
const CLOSED = 3;

export class ApcSocket {
  constructor(url, options = {}) {
    this.url = String(url);
    this.readyState = CONNECTING;
    this.protocol = "";
    this.binaryType = "blob";
    this.bufferedAmount = 0;
    this.extensions = "";

    this.onopen = null;
    this.onmessage = null;
    this.onerror = null;
    this.onclose = null;
    this.listeners = new Map();

    this.handler = options.handler ?? "ZCL_APC_DEMO_HANDLER";
    this.abap = options.abap ?? globalThis.abap;
    this.host = undefined;
    this.queue = Promise.resolve();

    // the page calls new WebSocket( ) and expects to be able to attach
    // handlers before anything happens, so the open is a turn later
    this.queue = this.queue.then(() => this.#open());
  }

  addEventListener(type, listener) {
    if (this.listeners.has(type) === false) {
      this.listeners.set(type, []);
    }
    this.listeners.get(type).push(listener);
  }

  removeEventListener(type, listener) {
    const list = this.listeners.get(type) ?? [];
    const at = list.indexOf(listener);
    if (at >= 0) {
      list.splice(at, 1);
    }
  }

  send(data) {
    if (this.readyState !== OPEN && this.readyState !== CONNECTING) {
      throw new Error("ApcSocket: send on a socket that is not open");
    }
    // every send is a message into the handler and whatever it pushed comes
    // back, in order, one call after another rather than in parallel: a
    // stateful handler is one object and two messages at once would race
    this.queue = this.queue.then(() => this.#message(data)).catch((error) => this.#fail(error));
  }

  close(code = 1000, reason = "closed by the page") {
    if (this.readyState === CLOSED || this.readyState === CLOSING) {
      return;
    }
    this.readyState = CLOSING;
    this.queue = this.queue.then(async () => {
      if (this.host !== undefined) {
        await this.host.close({iv_reason: this.#text(reason), iv_code: code});
      }
      this.readyState = CLOSED;
      this.#emit("close", {code, reason, wasClean: true});
    }).catch((error) => this.#fail(error));
  }

  // ------------------------------------------------------------- internals

  #text(value) {
    return new this.abap.types.String().set(String(value));
  }

  async #open() {
    try {
      const host = this.abap?.Classes?.["ZCL_APC_HOST"];
      if (host === undefined) {
        throw new Error("ApcSocket: ZCL_APC_HOST is not in the runtime, transpile open-abap-apc first");
      }
      this.host = await (new host()).constructor_({iv_handler: this.#text(this.handler)});
      const accepted = await this.host.open();
      if (accepted.get() !== "X") {
        // a handler that rejects the connection is not an error, it is a
        // refusal, and a page sees the same thing it would see from a system
        this.readyState = CLOSED;
        this.#emit("close", {code: 1008, reason: "the handler rejected the connection", wasClean: true});
        return;
      }
      this.readyState = OPEN;
      this.#emit("open", {});
      await this.#drain();
    } catch (error) {
      this.#fail(error);
    }
  }

  async #message(data) {
    if (this.host === undefined || this.readyState === CLOSED) {
      return;
    }
    await this.host.message({iv_text: this.#text(typeof data === "string" ? data : String(data))});
    await this.#drain();
  }

  // what the handler pushed while it was running, in order
  async #drain() {
    const frames = await this.host.drain();
    for (const row of frames.array()) {
      const text = row.get();
      this.#emit("message", {data: typeof text?.get === "function" ? text.get() : String(text)});
    }
  }

  #emit(type, event) {
    const full = {type, target: this, ...event};
    const handler = this[`on${type}`];
    if (typeof handler === "function") {
      handler.call(this, full);
    }
    for (const listener of this.listeners.get(type) ?? []) {
      listener.call(this, full);
    }
  }

  #fail(error) {
    const message = String(error?.message?.get?.() ?? error?.message ?? error);
    this.#emit("error", {message});
    if (this.readyState !== CLOSED) {
      this.readyState = CLOSED;
      this.#emit("close", {code: 1011, reason: message, wasClean: false});
    }
  }
}

ApcSocket.CONNECTING = CONNECTING;
ApcSocket.OPEN = OPEN;
ApcSocket.CLOSING = CLOSING;
ApcSocket.CLOSED = CLOSED;

// Replace the page's WebSocket, optionally only for the URLs that belong to
// APC, so a page that also talks to something real keeps that.
export function install(options = {}) {
  const target = options.target ?? globalThis;
  const real = target.WebSocket;
  const matches = options.match ?? ((url) => /\/sap\/bc\/apc\//.test(String(url)));

  class Socket extends ApcSocket {
    constructor(url, protocols) {
      if (matches(url) === false && real !== undefined) {
        // not ours: hand it back to the real one
        return new real(url, protocols);
      }
      super(url, options);
    }
  }
  Socket.CONNECTING = CONNECTING;
  Socket.OPEN = OPEN;
  Socket.CLOSING = CLOSING;
  Socket.CLOSED = CLOSED;

  target.WebSocket = Socket;
  return () => {
    target.WebSocket = real;
  };
}
