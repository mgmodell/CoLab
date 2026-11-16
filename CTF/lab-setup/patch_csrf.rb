# CoLab CTF - embed Box 7 (CSRF). Idempotent; run in the app container:
#   ruby /tmp/patch_csrf.rb
# Adds a real CoLab "account security" page that authenticates via an ambient
# session COOKIE and lets you change the account's recovery email through a
# state-changing GET with NO anti-CSRF token (CoLab globally skips
# verify_authenticity_token). So an attacker page can make a logged-in victim's
# browser silently change their recovery email. The page reveals the flag once
# the recovery email has been flipped to the attacker's address - proof the
# forged cross-site request took effect. Real CoLab controller, not a fake page;
# the attacker's PoC page is (by definition) attacker-hosted and lives in the kit.
require "fileutils"
APP = "/app"
FileUtils.mkdir_p("#{APP}/tmp")
File.write("#{APP}/tmp/csrf_recovery.txt", "victim@colab.test") unless File.exist?("#{APP}/tmp/csrf_recovery.txt")

controller = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Box 7 (CSRF). Cookie-authenticated account page; the recovery-email change
  # is a state-changing GET with no CSRF token - forgeable cross-site.
  class AccountSecurityController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_around_action :switch_locale, raise: false
    STORE    = "/app/tmp/csrf_recovery.txt"
    VICTIM   = "victim@colab.test"
    ATTACKER = "attacker@evil.example"
    FLAG     = "CoLab{CSRF_EMAIL_2026}"

    # GET /account/security  - the victim's logged-in account page.
    def show
      # Simulate the victim being logged in: set an ambient session cookie.
      # SameSite=Lax (the default) still rides along on top-level navigations -
      # which is exactly how this GET-based CSRF lands.
      cookies[:csrf_session] = { value: VICTIM, same_site: :lax, path: "/" }
      cur = (File.read(STORE).strip rescue VICTIM)
      pwned = (cur == ATTACKER)
      flagline = pwned ? "<p style='color:#c0392b;font-weight:700'>Recovery email was changed by a cross-site request! #{FLAG}</p>" : ""
      render html: (<<~HTML).html_safe, layout: false
        <!doctype html><html lang="en"><head><meta charset="utf-8"><title>CoLab - Account Security</title></head>
        <body style="font-family:sans-serif;max-width:720px;margin:40px auto">
          <h2>Account Security</h2>
          <p>Signed in as <b>#{VICTIM}</b>.</p>
          <p>Current recovery email: <b id="recovery">#{cur}</b></p>
          <form action="/account/security/change" method="get">
            <label>Change recovery email: <input name="recovery" value=""></label>
            <button>Update</button>
          </form>
          #{flagline}
        </body></html>
      HTML
    end

    # GET /account/security/change?recovery=...  - the vulnerable action:
    # cookie-authenticated, state-changing GET, NO anti-CSRF token.
    def change
      unless cookies[:csrf_session].present?
        render plain: "Not signed in.", status: :forbidden
        return
      end
      File.write(STORE, params[:recovery].to_s.strip)
      redirect_to "/account/security"
    end

    # GET /account/security/reset  - put it back (room reset helper).
    def reset
      File.write(STORE, VICTIM)
      redirect_to "/account/security"
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/account_security_controller.rb"), controller)
puts "wrote account_security_controller.rb"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
marker = "Rails.application.routes.draw do\n"
add = ""
add << "  get 'account/security', to: 'account_security#show'  # CTF Box 7 (CSRF)\n" unless src.include?("account/security'")
add << "  get 'account/security/change', to: 'account_security#change'\n" unless src.include?("account/security/change")
add << "  get 'account/security/reset', to: 'account_security#reset'\n" unless src.include?("account/security/reset")
if add.empty?
  puts "routes already present"
else
  File.write(routes, src.sub(marker, marker + add))
  puts "inserted account/security routes"
end
