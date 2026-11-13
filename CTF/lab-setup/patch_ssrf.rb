# CoLab CTF - embed Box 11 (SSRF). Idempotent; run in the app container:
#   ruby /tmp/patch_ssrf.rb
# Plants a loopback-only "internal cloud metadata" service that holds a secret,
# reachable ONLY from the host itself (127.0.0.1). The real, unguarded SSRF in
# LtiController#register (GET /lti/tool_connect?openid_configuration=<url>) lets
# an outside attacker make CoLab fetch that internal service on their behalf and
# reflects its response body back - leaking the secret. Nothing here is faked:
# the SSRF already exists; we only add a juicy internal target + a secret.
require "fileutils"
APP = "/app"

controller = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Box 11 (SSRF) target. Simulated internal-only metadata service (think
  # 169.254.169.254 cloud metadata): holds a secret and must only be reachable
  # from the host loopback. It is NOT routable from outside - an attacker reaches
  # it only by pivoting through CoLab's SSRF in /lti/tool_connect.
  class InternalController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_around_action :switch_locale, raise: false

    SSRF_FLAG = "CoLab{SSRF_METADATA_2026}"

    def metadata
      peer = request.remote_addr.to_s
      unless %w[127.0.0.1 ::1 ::ffff:127.0.0.1].include?(peer)
        render plain: "403 Forbidden - internal metadata service (loopback only)",
               status: :forbidden
        return
      end
      if request.post?
        # CoLab's LTI "registration" callback POSTs here; we answer non-2xx so the
        # body is surfaced to the caller through the registration-error reflection.
        render plain: "internal metadata access key: #{SSRF_FLAG}", status: :forbidden
      else
        render json: {
          issuer: "internal-metadata-service",
          registration_endpoint: "http://127.0.0.1:3000/internal/metadata"
        }
      end
    end
  end
RUBY

path = File.join(APP, "app/controllers/internal_controller.rb")
File.write(path, controller)
puts "wrote #{path}"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
if src.include?("internal/metadata")
  puts "route already present"
else
  marker = "Rails.application.routes.draw do\n"
  inject = marker + "  match 'internal/metadata', to: 'internal#metadata', via: %i[get post]  # CTF Box 11 (SSRF) target\n"
  src = src.sub(marker, inject)
  File.write(routes, src)
  puts "inserted internal/metadata route"
end
