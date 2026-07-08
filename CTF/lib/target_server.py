#!/usr/bin/env python3
# ============================================================================
#  CoLab CTF — real HTTP target server.
#  Turns the offline challenge mocks into a genuine attackable HTTP service so
#  the Sec toolkit (curl, sqlmap, ffuf, nuclei, nmap, …) can hit a real IP:port.
#  Each request is routed to the CURRENTLY ACTIVE room's handler via
#  `ctf.sh __serve <id> …` (CTF_RAW=1 for a machine-readable response).
#  Bind: 0.0.0.0:${CTF_TARGET_PORT:-8000}.  Active room: state/active_challenge.
# ============================================================================
import os
import subprocess
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, unquote_plus

CTF_HOME = os.environ.get("CTF_HOME") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORT = int(os.environ.get("CTF_TARGET_PORT", "8000"))
ACTIVE_FILE = os.path.join(CTF_HOME, "state", "active_challenge")
CTF_SH = os.path.join(CTF_HOME, "ctf.sh")

LANDING = (
    "CoLab CTF target — online.\n"
    "No room is active yet. Open a room from the CTF menu; this target then\n"
    "serves that room's endpoints. Then attack it, e.g.:\n"
    "  curl http://<this-host>:%d/<endpoint>\n" % PORT
)


def active_challenge():
    try:
        with open(ACTIVE_FILE) as f:
            return f.read().strip()
    except OSError:
        return ""


def serve_via_handler(cid, method, path, query, headers, body):
    p = path + ("?" + unquote_plus(query) if query else "")
    args = ["bash", CTF_SH, "__serve", cid, method, p]
    if headers.get("Authorization"):
        args += ["-H", "Authorization: " + headers.get("Authorization")]
    if headers.get("X-CSRF-Token"):
        args += ["-H", "X-CSRF-Token: " + headers.get("X-CSRF-Token")]
    if headers.get("Cookie"):
        args += ["-b", headers.get("Cookie")]
    if body:
        ctype = (headers.get("Content-Type") or "").lower()
        args += ["-d", unquote_plus(body) if "form-urlencoded" in ctype else body]
    env = dict(os.environ)
    env["CTF_RAW"] = "1"
    try:
        out = subprocess.run(args, capture_output=True, text=True, env=env, timeout=20).stdout
    except Exception as e:  # noqa: BLE001
        return 500, "target error: %s" % e
    head, sep, rest = out.partition("\n\n")
    status = head.strip()
    return (int(status) if status.isdigit() else 200), (rest if sep else out)


class Handler(BaseHTTPRequestHandler):
    server_version = "CoLabCTF/1.0"

    def _dispatch(self, method):
        parts = urlsplit(self.path)
        cid = active_challenge()
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length).decode("utf-8", "replace") if length else ""
        if not cid:
            code, out = 200, LANDING
        else:
            code, out = serve_via_handler(cid, method, unquote_plus(parts.path), parts.query, self.headers, body)
        data = out.encode("utf-8", "replace")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):    self._dispatch("GET")
    def do_POST(self):   self._dispatch("POST")
    def do_PUT(self):    self._dispatch("PUT")
    def do_PATCH(self):  self._dispatch("PATCH")
    def do_DELETE(self): self._dispatch("DELETE")
    def do_HEAD(self):   self._dispatch("GET")

    def log_message(self, *a):  # keep the CTF console quiet
        pass


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
