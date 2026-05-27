import http.server
import socketserver
import sys
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8123
ROOT = Path(__file__).parent / "build" / "web"


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        # Required for dart2wasm to use SharedArrayBuffer / multi-threading.
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


Handler.extensions_map.update({
    ".wasm": "application/wasm",
    ".mjs": "text/javascript",
    ".js": "text/javascript",
})

with socketserver.TCPServer(("127.0.0.1", PORT), Handler) as httpd:
    print(f"Serving {ROOT} at http://127.0.0.1:{PORT}/")
    httpd.serve_forever()
