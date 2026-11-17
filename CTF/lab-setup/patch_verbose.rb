# CoLab CTF - embed Box 4 (Sensitive Data Exposure: verbose errors). Idempotent;
# run in the app container:  ruby /tmp/patch_verbose.rb
# Adds a real (unauthenticated) report diagnostics endpoint that was shipped with
# debug-style error handling: the happy path works, but any unhandled format
# rescues the exception and renders the full backtrace + an ENV/config dump -
# including the report signing key - straight to the client. Classic A05
# security misconfiguration. Rendered by a REAL CoLab controller, not a fake page.
require "fileutils"
APP = "/app"

controller = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Box 4 (Sensitive Data Exposure). A diagnostics report endpoint left with
  # verbose debug error output in production: unhandled input dumps a backtrace +
  # config to the client, leaking REPORT_SIGNING_KEY.
  class DiagnosticsController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_around_action :switch_locale, raise: false

    REPORT_SIGNING_KEY = "CoLab{VERBOSE_SECRETS_2026}"

    def report
      fmt = params[:format_type].to_s
      raise ArgumentError, "unsupported report format: #{fmt.inspect}" unless fmt == "pdf"
      render json: { report: "generated", format: "pdf", rows: 12 }
    rescue => e
      # DEBUG error handler left enabled in production (the bug): echoes the
      # exception and a config/ENV dump to the client.
      body = <<~ERR
        #{e.class}: #{e.message}
          app/services/report_generator.rb:44:in `render'
          app/controllers/diagnostics_controller.rb:12:in `report'

        -- environment (debug dump) --
          RAILS_ENV=production
          DB_HOST=db.internal
          REPORT_SIGNING_KEY=#{REPORT_SIGNING_KEY}
          (full backtrace rendered to client - debug error pages left on)
      ERR
      render plain: body, status: :internal_server_error
    end
  end
RUBY

path = File.join(APP, "app/controllers/diagnostics_controller.rb")
File.write(path, controller)
puts "wrote #{path}"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
if src.include?("diagnostics/report")
  puts "route already present"
else
  marker = "Rails.application.routes.draw do\n"
  inject = marker + "  get 'diagnostics/report', to: 'diagnostics#report', defaults: { format: 'json' }  # CTF Box 4 (verbose errors)\n"
  File.write(routes, src.sub(marker, inject))
  puts "inserted diagnostics/report route"
end
