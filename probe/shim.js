// What a conservative engine has to put on the table before transpiled ABAP
// runs. Each of these is here because the bundle asked for it; the list is
// the answer to "what does @abaplint/runtime need that goja lacks".
(function (g) {
  // string templates with a DATE or TIME format option
  // (runtime/src/template_formatting.ts)
  if (typeof g.Intl === "undefined") {
    var pad = function (n, w) { var s = String(n); while (s.length < w) { s = "0" + s; } return s; };
    g.Intl = {
      DateTimeFormat: function (locale, options) {
        options = options || {};
        return {
          format: function (date) {
            var d = date instanceof Date ? date : new Date(date);
            if (options.hour !== undefined || options.minute !== undefined) {
              return pad(d.getHours(), 2) + ":" + pad(d.getMinutes(), 2) + ":" + pad(d.getSeconds(), 2);
            }
            return pad(d.getDate(), 2) + "." + pad(d.getMonth() + 1, 2) + "." + d.getFullYear();
          },
          resolvedOptions: function () { return {timeZone: "UTC", locale: "default"}; },
        };
      },
      NumberFormat: function () {
        return {format: function (n) { return String(n); }};
      },
    };
  }

  // SET HANDLER keeps a weak reference to the receiver
  // (runtime/src/abap_eventing.ts); this one leaks, which is fine for a
  // process that starts, serves and exits
  if (typeof g.WeakRef === "undefined") {
    g.WeakRef = function (target) { this._t = target; };
    g.WeakRef.prototype.deref = function () { return this._t; };
  }

  // the runtime converts hex, utf16le and utf8 through Node's Buffer
  // (runtime/src/types/hex_uint8.ts, types/field_symbol.ts, builtin/index.ts)
  if (typeof g.Buffer === "undefined") {
    var fromHex = function (s) {
      var out = [];
      for (var i = 0; i + 1 < s.length; i += 2) { out.push(parseInt(s.substr(i, 2), 16)); }
      return out;
    };
    var fromUtf16le = function (s) {
      var out = [];
      for (var i = 0; i < s.length; i++) { var c = s.charCodeAt(i); out.push(c & 255, c >> 8); }
      return out;
    };
    var fromUtf8 = function (s) {
      var out = [];
      for (var i = 0; i < s.length; i++) {
        var c = s.charCodeAt(i);
        if (c < 128) { out.push(c); }
        else if (c < 2048) { out.push(192 | (c >> 6), 128 | (c & 63)); }
        else { out.push(224 | (c >> 12), 128 | ((c >> 6) & 63), 128 | (c & 63)); }
      }
      return out;
    };
    var B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function Buf(bytes) {
      var a = new Uint8Array(bytes);
      a.toString = function (encoding) {
        var i, s = "";
        if (encoding === "hex") {
          for (i = 0; i < a.length; i++) { s += (a[i] < 16 ? "0" : "") + a[i].toString(16); }
          return s;
        }
        if (encoding === "utf16le" || encoding === "ucs2") {
          for (i = 0; i + 1 < a.length; i += 2) { s += String.fromCharCode(a[i] | (a[i + 1] << 8)); }
          return s;
        }
        if (encoding === "base64") {
          for (i = 0; i < a.length; i += 3) {
            var b0 = a[i], b1 = a[i + 1], b2 = a[i + 2];
            s += B64[b0 >> 2] + B64[((b0 & 3) << 4) | ((b1 || 0) >> 4)];
            s += b1 === undefined ? "=" : B64[((b1 & 15) << 2) | ((b2 || 0) >> 6)];
            s += b2 === undefined ? "=" : B64[b2 & 63];
          }
          return s;
        }
        for (i = 0; i < a.length; i++) { s += String.fromCharCode(a[i]); }
        return s;
      };
      return a;
    }

    g.Buffer = {
      from: function (value, encoding) {
        if (typeof value !== "string") { return Buf(value); }
        if (encoding === "hex") { return Buf(fromHex(value)); }
        if (encoding === "utf16le" || encoding === "ucs2") { return Buf(fromUtf16le(value)); }
        if (encoding === "base64") {
          var clean = value.replace(/[^A-Za-z0-9+/]/g, ""), out = [], i;
          for (i = 0; i < clean.length; i += 4) {
            var n = (B64.indexOf(clean[i]) << 18) | (B64.indexOf(clean[i + 1]) << 12)
                  | ((B64.indexOf(clean[i + 2]) & 63) << 6) | (B64.indexOf(clean[i + 3]) & 63);
            out.push((n >> 16) & 255);
            if (clean[i + 2] !== undefined) { out.push((n >> 8) & 255); }
            if (clean[i + 3] !== undefined) { out.push(n & 255); }
          }
          return Buf(out);
        }
        return Buf(fromUtf8(value));
      },
      alloc: function (n) { return Buf(new Uint8Array(n)); },
      allocUnsafe: function (n) { return Buf(new Uint8Array(n)); },
      concat: function (list) {
        var total = 0, i;
        for (i = 0; i < list.length; i++) { total += list[i].length; }
        var out = new Uint8Array(total), at = 0;
        for (i = 0; i < list.length; i++) { out.set(list[i], at); at += list[i].length; }
        return Buf(out);
      },
      isBuffer: function (v) { return v instanceof Uint8Array; },
    };
  }
})(globalThis);
