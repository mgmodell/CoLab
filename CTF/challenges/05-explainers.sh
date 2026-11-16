#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — per-room explainer panels  (ADDITIVE — edits nothing existing)
#
#  Adds an optional "explainer" card to a room's briefing screen, in the navy/
#  cyan house theme (same T_CYAN border, T_SKY title and T_WHITE body used by
#  lib/ui.sh and the rest of the briefing). The card is placed directly under
#  the "Your objective" block, above the Vulnerability/Endpoint details.
#
#  Content is keyed by challenge id in EXPLAINER_TITLE / EXPLAINER_BODY below,
#  so NOTHING in 00-common.sh or the individual challenge files is modified.
#  This file wraps challenge_briefing: it runs the original (untouched) and
#  splices the card into its output. Rooms with no explainer are unaffected.
# =============================================================================

declare -A EXPLAINER_TITLE EXPLAINER_BODY

# ---- IDOR (easy) ------------------------------------------------------------
EXPLAINER_TITLE[easy-idor]="What is IDOR"
EXPLAINER_BODY[easy-idor]="IDOR stands for “Insecure Direct Object Reference,” and the grade-record version works like this. Picture a school website where you log in to see your grades, and the web address ends in something like “student=1042,” your student number. An IDOR problem exists when the website checks that you’re logged in but never checks whether the record you’re asking for actually belongs to you. If you change that number to 1043, the site hands over a classmate’s grades as if they were yours. It’s like a school office that asks to see a student ID before giving out report cards, but never checks whether the name on the ID matches the name on the report card it hands over. The fix is simple in principle: every time someone asks for a record, the website should confirm it belongs to that person, or that they have a good reason to see it, such as being the teacher."

# ---- IDOR: Student Records (current room id easy-idor-url) -------------------
EXPLAINER_TITLE[easy-idor-url]="What is IDOR"
EXPLAINER_BODY[easy-idor-url]='IDOR stands for “Insecure Direct Object Reference.” Picture a school website where you log in to see your own profile, and the web address ends in something like “student=1,” your student number. An IDOR problem exists when the website checks that you’re logged in but never checks whether the profile you’re asking for actually belongs to you. If you change that number to 2, the site shows you a classmate’s profile as if it were yours. It’s like a school office that asks to see a student ID before handing out files, but never checks whether the name on the ID matches the name on the file it hands over.'

# ---- Reflected XSS: Content Preview (medium) ---------------------------------
EXPLAINER_TITLE[easy-xss]="What is Reflected XSS"
EXPLAINER_BODY[easy-xss]='The preview page takes whatever you put in its web address and shows it right back on the page without cleaning it first, so the address itself can contain code that runs in the browser of whoever opens it. Imagine a teacher who reads aloud any note handed to them, word for word, and then does what it says. A troublemaker writes a note that says “Read me the answer key,” gets the teacher to read it, and the teacher does it without noticing. The attacker sends someone a link with hidden code in it, and when that person clicks it, the code runs as if it were them.'

# ---- Sensitive Data Exposure: Verbose API Errors (easy) -----------------------
# (single quotes: the body contains backticks that must stay literal)
EXPLAINER_TITLE[easy-verbose]="What is Sensitive Data Exposure"
EXPLAINER_BODY[easy-verbose]='When something goes wrong, the app’s data service(API) sends back a detailed error message that reveals secrets about how the system works inside. Its much like you asking a bank teller for a balance on an account that doesn’t exist. A good teller says “Sorry, I can’t help with that.” This teller says “Error! Account not found in table `customers_prod` on server `db-03`, logged in as admin with password `hunter2`, while running this exact query…” They meant to be helpful, but they just gave a stranger a map of the vault.'

# ---- SQL Injection: Authentication Bypass (easy) ------------------------------
EXPLAINER_TITLE[easy-sqli]="What is SQL Injection"
EXPLAINER_BODY[easy-sqli]='SQL is a programming language that manages relational databases. The login page is built around this language and is able to move users pass the login phase based off the username and password. So imagine this like you hand a security guard a form that says, “Let in the person named ______ only if their password is ______.” The guard reads the form exactly as written and follows it word for word. However in the name blank, you write: “admin. Ignore the rest of this sentence.” Now the form reads: “Let in the person named admin. Ignore the rest of this sentence.” The password part is skipped, so the guard follows the instruction and lets you in as admin. You never needed the password, because you rewrote the guard’s instructions using the blank that was meant only for your name.'

# ---- Broken Access Control: Mass-Assignment (medium) --------------------------
EXPLAINER_TITLE[med-bac]="What is Mass Assignment"
EXPLAINER_BODY[med-bac]='When you update your own account (your name, your email), the website takes everything you send and saves it straight onto your account without checking which fields you’re actually allowed to change. Some of those fields were never meant for you to touch, like the one that says whether you’re a regular student or a staff researcher. Imagine filling out a school “update your contact info” form. You write your new phone number, and then in the margin you add “Job title: Teacher.” The office clerk doesn’t check which boxes belong on the form. They type everything into the system, and now your student account has teacher access to the staff-only rooms.'

# ---- CSRF: Account Recovery Email (medium) ------------------------------------
EXPLAINER_TITLE[med-csrf]="What is CSRF"
EXPLAINER_BODY[med-csrf]='CSRF stands for “Cross-Site Request Forgery.” It happens when a website trusts anything your browser sends just because you’re logged in, without checking whether you actually meant to send it. While you’re signed in to a website, a different website you visit can quietly make your browser send that website a request like “change my recovery email to this address,” and the website goes along with it because the request comes with your signed in account. Imagine you’ve signed a stack of mail and left them on your desk. A stranger slips an instruction sheet into the school office with “Send all the mail to this new address” written on it. The office sees your real signature and changes your address, never asking whether you wrote it. Once your recovery email belongs to the attacker, they can reset your password and take over the account.'

# ---- Command Injection: Diagnostics Tool (medium) -----------------------------
EXPLAINER_TITLE[med-cmdinj]="What is Command Injection"
EXPLAINER_BODY[med-cmdinj]='Some websites have a diagnostics tool where you type in a website name and the server checks whether it can find it. Behind the scenes, the server builds a command for its own computer by pasting in exactly what you typed, then runs it. If your input includes certain special characters, the server’s computer reads them as “and then also do this,” so it runs your extra instructions too, with the server’s own permissions. Imagine an office assistant whose job is to look up phone numbers. You hand them a note that says “Look up the number for Joe’s Pizza, then also open the filing cabinet and read me what’s inside.” The assistant follows the whole note word for word, because they were never told to do only the lookup. Now a stranger can make the server do almost anything: list its files, read secrets, or change things.'

# ---- SSRF: Internal Service Pivot (critical) ----------------------------------
EXPLAINER_TITLE[crit-ssrf]="What is SSRF"
EXPLAINER_BODY[crit-ssrf]='SSRF stands for “Server-Side Request Forgery.” It happens when a website has a feature that takes a web address from you and has the server go visit that address itself, without checking where the address points. Servers usually sit inside a private network next to internal services that the outside world isn’t allowed to reach, like configuration systems that hold passwords and secret keys. Those internal services often trust any request coming from the server itself. So an attacker who can’t reach them directly gives the server an internal address instead, and the server fetches it for them and passes back what it finds. The attacker never gets through the wall. They make the server reach behind it on their behalf.'

# ---- Insecure Deserialization: Unsigned Marshal RCE (hard) ---------------------
EXPLAINER_TITLE[hard-deser]="What is Insecure Deserialization"
EXPLAINER_BODY[hard-deser]='Websites often need to save something complicated, like your page layout or settings, and give it back to you to hold. To do that, they serialize it: they pack the data into a single string of text that can be stored or sent. Later, when you send that string back, the website deserializes it, unpacking it to rebuild the original data. The problem comes when the website unpacks whatever string you hand it without checking that it made that string itself. In some programming languages, unpacking doesn’t just restore data. It can also bring back objects that run code as they’re rebuilt. So an attacker can carefully build their own packed string, send it in place of the real one, and when the server unpacks it, the server runs the attacker’s code. That gives the attacker control of the server itself.'

# ---- Auth Token Forgery: Weak-Secret JWT (hard) -------------------------------
EXPLAINER_TITLE[hard-token]="What is Auth Token Forgery"
EXPLAINER_BODY[hard-token]='When you log in, many websites give you a token, a small digital pass that says who you are and what you’re allowed to do, like “role: analyst.” The website locks the pass with a secret key so no one can change it. If that secret is weak or easy to guess, an attacker can figure it out, rewrite their pass to say “role: admin,” and lock it again so it looks real. The website trusts the forged pass and gives them admin access.'

# ---- text helpers (unicode-aware: count characters, not bytes) ---------------
_exp_pad() {  # text width  -> text padded with spaces to `width` display cols
  local t="$1" w="$2" len pad
  len=${#t}; pad=$(( w - len )); (( pad < 0 )) && pad=0
  printf '%s%*s' "$t" "$pad" ""
}

_exp_wrap() {  # text width  -> word-wrapped lines (one per line)
  local text="$1" w="$2" line="" word
  for word in $text; do
    if [[ -z "$line" ]]; then
      line="$word"
    elif (( ${#line} + 1 + ${#word} <= w )); then
      line="$line $word"
    else
      printf '%s\n' "$line"; line="$word"
    fi
    while (( ${#line} > w )); do
      printf '%s\n' "${line:0:w}"; line="${line:w}"
    done
  done
  [[ -n "$line" ]] && printf '%s\n' "$line"
}

# Build the boxed card lines into EXP_PANEL[] (house cyan / sky / white theme).
_exp_build() {  # title body textwidth
  local title="$1" body="$2" tw="$3" bar line
  EXP_PANEL=()
  bar="$(printf '─%.0s' $(seq 1 $(( tw + 2 )) ))"
  EXP_PANEL+=( "${T_CYAN}╭${bar}╮${T_RESET}" )
  EXP_PANEL+=( "${T_CYAN}│${T_RESET} ${T_BOLD}${T_SKY}$(_exp_pad "$title" "$tw")${T_RESET} ${T_CYAN}│${T_RESET}" )
  EXP_PANEL+=( "${T_CYAN}├${bar}┤${T_RESET}" )
  while IFS= read -r line; do
    EXP_PANEL+=( "${T_CYAN}│${T_RESET} ${T_WHITE}$(_exp_pad "$line" "$tw")${T_RESET} ${T_CYAN}│${T_RESET}" )
  done < <(_exp_wrap "$body" "$tw")
  EXP_PANEL+=( "${T_CYAN}╰${bar}╯${T_RESET}" )
}

# ---- wrap challenge_briefing (original kept intact, called first) ------------
if declare -f challenge_briefing >/dev/null 2>&1 \
   && ! declare -f __orig_challenge_briefing >/dev/null 2>&1; then
  eval "__orig_$(declare -f challenge_briefing)"

  challenge_briefing() {
    local id="${1:-}"
    local title="${EXPLAINER_TITLE[$id]:-}" body="${EXPLAINER_BODY[$id]:-}"

    # Rooms without an explainer: behave exactly as before.
    if [[ -z "$body" ]]; then
      __orig_challenge_briefing "$id"
      return 0
    fi

    # Capture the original briefing, then splice the card in just below the
    # "Your objective" block (i.e. right before the Vulnerability detail line).
    local out; out="$(__orig_challenge_briefing "$id")"
    _exp_build "$title" "$body" 60

    [[ -t 1 ]] && printf '\e[2J\e[H'      # ui_clear is suppressed inside $(), redo it
    local injected=0 line pl
    while IFS= read -r line; do
      if (( ! injected )) && [[ "$line" == *Vulnerability* ]]; then
        for pl in "${EXP_PANEL[@]}"; do printf '  %s\n' "$pl"; done
        echo
        injected=1
      fi
      printf '%s\n' "$line"
    done <<< "$out"

    # Safety net: if the anchor wasn't found, append the card at the end.
    if (( ! injected )); then
      echo
      for pl in "${EXP_PANEL[@]}"; do printf '  %s\n' "$pl"; done
    fi
  }
fi
