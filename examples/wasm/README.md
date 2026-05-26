# wiredash_wasm

Minimal Flutter sample that compiles Wiredash to **WebAssembly** via `dart2wasm`.

The point of this sample is not the UI — it is to verify that Wiredash and its entire transitive dependency graph compile to wasm without falling back to `dart:html` / `dart:js`.

## Build

```sh
flutter build web --wasm
```

A successful build produces:

- `build/web/main.dart.wasm` — the compiled wasm module
- `build/web/main.dart.mjs` — the wasm loader
- `build/web/main.dart.js` — JS fallback (for browsers without wasm-GC support)

To produce a wasm-only build with no JS fallback:

```sh
flutter build web --wasm --strip-wasm
```

## Run

A static file server is included that sets the COOP / COEP headers wasm needs for `SharedArrayBuffer`:

```sh
flutter build web --wasm
python3 serve.py 8123
```

Then open <http://127.0.0.1:8123/>.

To confirm you are actually running wasm and not the JS fallback, check DevTools → Network for `main.dart.wasm` being loaded, or run in the console:

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
