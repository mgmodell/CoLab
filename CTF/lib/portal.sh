#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — the vulnerable "CoLab" site the students attack in the browser.
#  Each room with a CH_PORTAL hook renders its own CoLab-branded page; the
#  target server serves it at "/". This is the LMS the student is hacking into,
#  not a raw API dump. Rooms without a portal fall back to the task briefing.
# =============================================================================

_portal_esc() { local s="$1"; s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"; printf '%s' "$s"; }

# Shared CoLab chrome so every room's page reads as the same product.
colab_head() { # page-title  active-nav
  local title="$1" active="${2:-}"
  cat <<HTML
<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CoLab · ${title}</title>
<style>
 :root{--indigo:#1a1ad6;--indigo-d:#10108f;--ink:#1a1f36;--mut:#5b6178;--line:#e6e7f2;--amber:#f0b429;--bg:#f5f6fc;--card:#fff;--cyan:#00c2d6}
 *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.6 "Segoe UI",system-ui,Arial,sans-serif}
 header{background:var(--indigo);color:#fff;padding:12px 22px;display:flex;align-items:center;gap:14px}
 .logo{width:34px;height:34px;flex:0 0 34px}
 .brand{font-weight:700;font-size:20px;letter-spacing:.01em} .brand small{font-weight:400;opacity:.82;font-size:13px;margin-left:8px}
 nav{margin-left:auto;display:flex;gap:20px;font-size:14px} nav a{color:#d7d8ff;text-decoration:none}
 nav a.active{color:#fff;border-bottom:2px solid var(--amber);padding-bottom:10px}
 .who{background:var(--indigo-d);color:#cfd0ff;font-size:13px;padding:6px 22px}
 main{max-width:860px;margin:26px auto;padding:0 18px}
 h1{font-size:23px;margin:.1em 0 .1em}
 .sub{color:var(--mut);margin:.2em 0 1em}
 .card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:18px 22px;margin:16px 0;box-shadow:0 1px 2px rgba(20,20,80,.05)}
 .row{display:flex;justify-content:space-between;gap:16px;padding:10px 0;border-bottom:1px solid var(--line)} .row:last-child{border:0}
 .k{color:var(--mut)} .v{font-weight:600;text-align:right}
 .pill{display:inline-block;background:#ececfb;color:var(--indigo-d);border-radius:999px;padding:2px 11px;font-size:13px;font-weight:600}
 .warn{background:#fff6e5;border:1px solid #f1cf84;color:#8a5a06;border-radius:10px;padding:11px 15px;margin:0 0 14px;font-size:14px}
 footer{color:var(--mut);font-size:12px;text-align:center;padding:26px}
 code{background:#eef0f8;border-radius:5px;padding:1px 6px;font:13px ui-monospace,Consolas,monospace;color:var(--indigo-d)}
</style></head><body>
<header>
 <svg class="logo" viewBox="0 0 100 100" aria-hidden="true">
  <circle cx="50" cy="50" r="30" fill="#00c2d6"/>
  <g stroke="#0c0c6e" stroke-width="3">
   <line x1="50" y1="50" x2="50" y2="15"/><line x1="50" y1="50" x2="83" y2="40"/>
   <line x1="50" y1="50" x2="70" y2="82"/><line x1="50" y1="50" x2="30" y2="82"/><line x1="50" y1="50" x2="17" y2="40"/></g>
  <g><circle cx="50" cy="15" r="9" fill="#00ff00"/><circle cx="83" cy="40" r="9" fill="#ff2a2a"/>
   <circle cx="70" cy="82" r="9" fill="#ffff00"/><circle cx="30" cy="82" r="9" fill="#ff6600"/><circle cx="17" cy="40" r="9" fill="#ff00ff"/></g>
 </svg>
 <span class="brand">CoLab <small>Collaborative Learning</small></span>
 <nav>
   <a $([[ "$active" == dashboard ]] && printf 'class="active"') href="/">Dashboard</a>
   <a $([[ "$active" == grades ]] && printf 'class="active"') href="/">My Grades</a>
   <a href="/">Courses</a><a href="/">Teams</a>
 </nav>
</header>
<div class="who">Signed in as <b>you</b> · student #1001 · Fall 2026</div>
<main>
HTML
}

colab_foot() { cat <<'HTML'
</main>
<footer>CoLab LMS · research-backed collaborative learning · © CoLab</footer>
</body></html>
HTML
}

# Dispatch "/" to the active room's CoLab page (or the briefing if it has none).
ctf_portal_html() { # id
  local id="$1" fn
  fn="${CH_PORTAL[$id]:-}"
  if [[ -n "$fn" ]] && declare -F "$fn" >/dev/null 2>&1; then "$fn" "$id"; return; fi
  ctf_brief_html "$id"
}
