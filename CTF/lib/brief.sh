#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — in-browser room briefing ("boot-up" screen).
#  Renders a self-contained HTML task card for the active room from its
#  registry data: the task at hand + the toolkit, and a pointer to the
#  terminal hint system. Deliberately NO solution hints here.
#  Served by target_server.py at "/" and "/lab" for the active room.
# =============================================================================

_brief_esc() { # minimal HTML escaping
  local s="$1"; s="${s//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"; printf '%s' "$s"
}

ctf_brief_html() { # id
  local id="$1"
  local title diff pts owasp endpoint scenario objective browse tools
  title="$(_brief_esc "${CH_TITLE[$id]:-CoLab CTF}")"
  diff="$(_brief_esc "${CH_DIFF[$id]:-}")"
  pts="${CH_POINTS[$id]:-}"
  owasp="$(_brief_esc "${CH_OWASP[$id]:-}")"
  endpoint="$(_brief_esc "${CH_ENDPOINT[$id]:-}")"
  scenario="$(_brief_esc "${CH_SCENARIO[$id]:-}")"
  objective="$(_brief_esc "${CH_OBJECTIVE[$id]:-}")"
  browse="${CH_BROWSE[$id]:-/}"
  tools="$(_brief_esc "${CH_TOOLS[$id]:-}")"

  local accent="#4ade80"
  case "${CH_DIFF[$id]:-}" in
    Medium) accent="#facc15" ;; Hard) accent="#fb923c" ;; Critical) accent="#f87171" ;;
  esac

  cat <<HTML
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CoLab CTF — ${title}</title>
<style>
  :root{--bg:#0a0e1a;--card:#111933;--line:#22305c;--ink:#e2e8f0;--mut:#94a3b8;--cy:#22d3ee;--accent:${accent}}
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.65 ui-sans-serif,Segoe UI,Roboto,Arial,sans-serif;padding:32px 16px}
  .wrap{max-width:760px;margin:0 auto}
  .brand{color:var(--cy);font-weight:600;letter-spacing:.14em;font-size:13px;text-transform:uppercase}
  h1{font-size:28px;margin:.25em 0 .1em;font-weight:600}
  .badge{display:inline-block;background:rgba(255,255,255,.06);border:1px solid var(--line);color:var(--accent);font-size:13px;font-weight:600;padding:3px 12px;border-radius:999px;margin-right:8px}
  .card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:22px 24px;margin:20px 0}
  .k{color:var(--mut);font-size:12px;letter-spacing:.1em;text-transform:uppercase;margin:0 0 6px}
  .task{font-size:18px;line-height:1.6}
  code{background:#0b1226;border:1px solid var(--line);border-radius:6px;padding:2px 7px;color:var(--cy);font:14px ui-monospace,Consolas,monospace}
  .cta{display:inline-block;margin-top:8px;background:var(--accent);color:#07140a;font-weight:700;text-decoration:none;padding:11px 20px;border-radius:10px}
  .cta:hover{filter:brightness(1.08)}
  .foot{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin-top:10px}
  .tool{background:#0b1226;border:1px solid var(--line);border-radius:8px;padding:4px 10px;font:13px ui-monospace,Consolas,monospace;color:var(--ink)}
  .mut{color:var(--mut)} .sm{font-size:13.5px}
  .rule{height:1px;background:var(--line);border:0;margin:18px 0}
</style></head>
<body><div class="wrap">
  <div class="brand">CoLab CTF · lab briefing</div>
  <h1>${title}</h1>
  <div><span class="badge">${diff} · ${pts} pts</span><span class="mut sm">${owasp}</span></div>

  <div class="card">
    <p class="k">The situation</p>
    <p>${scenario}</p>
    <hr class="rule">
    <p class="k">Your task</p>
    <p class="task">${objective}</p>
    <p class="sm mut">Work against: <code>${endpoint}</code></p>
    <a class="cta" href="${browse}" target="_blank" rel="noopener">Enter the CoLab site &rarr;</a>
  </div>

  <div class="card">
    <p class="k">Your toolkit</p>
    <div class="foot">
      <span class="tool">curl</span><span class="tool">httpie</span><span class="tool">jq</span>
      <span class="tool">sqlmap</span><span class="tool">ffuf</span><span class="tool">nmap</span>
      <span class="tool">jwt_tool</span><span class="tool">./colab-http</span>
    </div>
    <p class="sm mut" style="margin-top:12px">Everything runs in the CoLab CTF toolbox terminal that opened with this room.
    Stuck? Type <code>!hint</code> in that terminal — it adapts to the step you're actually on.</p>
  </div>
</div></body></html>
HTML
}
