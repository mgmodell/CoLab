# CoLab CTF - embed Room 10 (Auth Token Forgery: weak-secret JWT). Idempotent;
# run in the app container:  ruby /tmp/patch_jwt.rb   (then restart the app).
#
# Adds a small REPORTING API secured by a JSON Web Token:
#   POST /api/reports/auth   -> issues an HS256 JWT for a reporting account
#   GET  /api/reports/admin  -> admin-only data IFF the Bearer JWT is validly
#                               signed AND carries role=admin
# The signing secret is a WEAK dictionary word (the bug) - so a holder of ANY
# issued token can crack the secret offline (jwt_tool + rockyou) and re-forge a
# token with role=admin. NOTHING is handed to the player: they log in with their
# own low-privilege analyst account, receive a token, and escalate by
# cracking+forging it. JWT is implemented inline (no gem) so the weakness is
# self-contained. Rendered by a REAL CoLab controller.
require "fileutils"
APP = "/app"

ctrl = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Room 10 (Auth Token Forgery). A reporting API secured by HS256 JWTs signed
  # with a WEAK, dictionary secret. Any issued token can be cracked offline and
  # re-forged with role=admin. JWT encode/verify is inline (no gem).
  class ReportsApiController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :verify_authenticity_token, raise: false
    skip_around_action :switch_locale, raise: false

    # Weak signing secret: a common dictionary word (crackable from any token).
    JWT_SECRET = "sunshine"
    ADMIN_FLAG = "CoLab{TOKEN_FORGED_2026}"

    # Low-privilege reporting accounts issued to API clients.
    ACCOUNTS = {
      "analyst" => { "password" => "Analyst!2024", "role" => "analyst" }
    }.freeze

    def auth
      u = params[:username].to_s
      p = params[:password].to_s
      acct = ACCOUNTS[u]
      if acct && acct["password"] == p
        tok = _jwt_encode({ "user" => u, "role" => acct["role"], "iat" => Time.now.to_i })
        render json: { token: tok,
                       usage: "Authorization: Bearer <token> to GET /api/reports/admin" }
      else
        render json: { error: "invalid credentials" }, status: :unauthorized
      end
    end

    def admin
      tok = request.headers["Authorization"].to_s.sub(/\ABearer\s+/i, "")
      claims = _jwt_verify(tok)
      if claims.nil?
        render json: { error: "invalid or missing bearer token" }, status: :unauthorized
      elsif claims["role"].to_s == "admin"
        render json: { report: "ADMIN REPORT - full student data export unlocked",
                       flag: ADMIN_FLAG }
      else
        render json: { error: "role '#{claims['role']}' is not authorized for the admin report" },
               status: :forbidden
      end
    end

    private

    def _b64(bin);  Base64.urlsafe_encode64(bin).delete("=");  end
    def _b64d(str); Base64.urlsafe_decode64(str + "=" * ((4 - str.length % 4) % 4)); end

    def _jwt_encode(payload)
      seg = "#{_b64({ 'alg' => 'HS256', 'typ' => 'JWT' }.to_json)}.#{_b64(payload.to_json)}"
      "#{seg}.#{_b64(OpenSSL::HMAC.digest('SHA256', JWT_SECRET, seg))}"
    end

    def _jwt_verify(tok)
      h, p, s = tok.to_s.split(".")
      return nil unless h && p && s
      expect = _b64(OpenSSL::HMAC.digest("SHA256", JWT_SECRET, "#{h}.#{p}"))
      return nil unless expect == s
      JSON.parse(_b64d(p)) rescue nil
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/reports_api_controller.rb"), ctrl)
puts "wrote reports_api_controller.rb"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
marker = "Rails.application.routes.draw do\n"
add = ""
add << "  post 'api/reports/auth',  to: 'reports_api#auth',  defaults: { format: 'json' }  # CTF Room 10 (weak JWT)\n" unless src.include?("api/reports/auth")
add << "  get  'api/reports/admin', to: 'reports_api#admin', defaults: { format: 'json' }  # CTF Room 10 (weak JWT)\n" unless src.include?("api/reports/admin")
if add.empty?
  puts "routes already present"
else
  File.write(routes, src.sub(marker, marker + add))
  puts "inserted reports api routes"
end
