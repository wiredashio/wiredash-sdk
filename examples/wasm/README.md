# wiredash_wasm

Minimal Flutter sample that compiles Wiredash to **WebAssembly** via `dart2wasm`.

The point of this sample is not the UI — it is to verify that Wiredash and its entire transitive dependency graph compile to wasm without falling back to `dart:html` / `dart:js`.

## Build

`--strip-wasm` drops the JS fallback so any non-wasm code path becomes a hard build error rather than a silent downgrade.

```sh
../../wiresdk flutter build web --wasm --strip-wasm
```

Output:

- `build/web/main.dart.wasm` — the compiled wasm module
- `build/web/main.dart.mjs` — the wasm loader

## Run

A static file server is included that sets the COOP / COEP headers wasm needs for `SharedArrayBuffer`:

```sh
../../wiresdk flutter build web --wasm --strip-wasm
python3 serve.py 8123
```

Then open <http://127.0.0.1:8123/>.

To confirm `main.dart.wasm` is actually loaded, check DevTools → Network, or run in the console:

```js
performance.getEntriesByType('resource').filter(r => r.name.endsWith('.wasm'))
```

## What this sample verifies

- All Wiredash runtime dependencies resolve under a wasm-compatible web build.
- The Wiredash widget tree mounts on a wasm runtime.
- Calling `Wiredash.of(context).show()` opens the feedback flow on wasm.

## Related

- Flutter wasm docs: <https://flutter.dev/to/wasm>
- `package:web` migration guide: <https://dart.dev/interop/js-interop/package-web>
