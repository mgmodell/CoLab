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
import re
import subprocess
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, unquote_plus, parse_qs

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


_SAFE_ID_RE = re.compile(r"^[A-Za-z0-9._-]{1,64}$")
_SAFE_HEADER_RE = re.compile(r"^[\x20-\x7E]{0,4096}$")
_SAFE_PATH_QUERY_RE = re.compile(r"^[\x20-\x7E]{0,8192}$")
_ALLOWED_METHODS = {"GET", "POST", "PUT", "PATCH", "DELETE"}


def _safe_id(value, default=""):
    value = (value or "").strip()
    return value if _SAFE_ID_RE.match(value) else default


def _safe_header_value(value):
    value = value or ""
    if "\x00" in value or not _SAFE_HEADER_RE.match(value):
        return ""
    return value


def _safe_path_query(value):
    value = value or ""
    if "\x00" in value or not _SAFE_PATH_QUERY_RE.match(value):
        return ""
    return value


def active_challenge():
    try:
        with open(ACTIVE_FILE) as f:
            return f.read().strip()
    except OSError:
        return ""


def brief_html(cid):
    cid = _safe_id(cid)
    if not cid:
        return "<!doctype html><title>CoLab CTF</title><p>briefing unavailable</p>"
    try:
        out = subprocess.run(["bash", CTF_SH, "__brief", cid], capture_output=True, text=True, timeout=20).stdout
        return out or "<!doctype html><title>CoLab CTF</title><p>briefing unavailable</p>"
    except Exception as e:  # noqa: BLE001
        return "<!doctype html><title>CoLab CTF</title><p>briefing error: %s</p>" % e


def portal_html(cid, sid):
    cid = _safe_id(cid)
    sid = _safe_id(sid, default="")
    if not cid:
        return "<!doctype html><title>CoLab</title><p>CoLab is unavailable</p>"
    env = dict(os.environ)
    env["CTF_PORTAL_ID"] = sid
    try:
        out = subprocess.run(["bash", CTF_SH, "__portal", cid], capture_output=True, text=True, env=env, timeout=20).stdout
        return out or "<!doctype html><title>CoLab</title><p>CoLab is unavailable</p>"
    except Exception as e:  # noqa: BLE001
        return "<!doctype html><title>CoLab</title><p>CoLab error: %s</p>" % e


def serve_via_handler(cid, method, path, query, headers, body):
    cid = _safe_id(cid)
    method = method if method in _ALLOWED_METHODS else "GET"
    safe_path = _safe_path_query(path)
    safe_query = _safe_path_query(unquote_plus(query) if query else "")
    p = safe_path + ("?" + safe_query if safe_query else "")
    if not cid or not safe_path:
        return 400, "invalid request"

    args = ["bash", CTF_SH, "__serve", cid, method, p]
    auth = _safe_header_value(headers.get("Authorization"))
    csrf = _safe_header_value(headers.get("X-CSRF-Token"))
    cookie = _safe_header_value(headers.get("Cookie"))
    if auth:
        args += ["-H", "Authorization: " + auth]
    if csrf:
        args += ["-H", "X-CSRF-Token: " + csrf]
    if cookie:
        args += ["-b", cookie]
    if body:
        ctype = (headers.get("Content-Type") or "").lower()
        body_value = unquote_plus(body) if "form-urlencoded" in ctype else body
        body_value = _safe_path_query(body_value)
        if body_value:
            args += ["-d", body_value]
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
        path = unquote_plus(parts.path)
        cid = active_challenge()
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length).decode("utf-8", "replace") if length else ""
        ctype = "application/json"
        # "/" is the CoLab site the student attacks; "/lab" is the task briefing.
        if method == "GET" and path in ("/", "/index.html"):
            if not cid:
                code, out, ctype = 200, LANDING, "text/plain; charset=utf-8"
            else:
                sid = _safe_id((parse_qs(parts.query).get("id") or ["1001"])[0], default="1001")
                code, out, ctype = 200, portal_html(cid, sid), "text/html; charset=utf-8"
        elif method == "GET" and path in ("/lab", "/brief"):
            if not cid:
                code, out, ctype = 200, LANDING, "text/plain; charset=utf-8"
            else:
                code, out, ctype = 200, brief_html(cid), "text/html; charset=utf-8"
        elif not cid:
            code, out = 200, LANDING
        else:
            code, out = serve_via_handler(cid, method, path, parts.query, self.headers, body)
        data = out.encode("utf-8", "replace")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
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
