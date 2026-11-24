# CoLab CTF - embed Room 7 (Command Injection). Idempotent; run in the app
# container:  ruby /tmp/patch_cmdinj.rb   (then restart the app).
#
# Adds a network-diagnostics "ping" tool that interpolates the `host` parameter
# straight into a shell command (the bug). Any shell metacharacter the attacker
# supplies runs on the server. NOTHING is handed to the player - they inject the
# command themselves; the flag is a file in the tool's working dir they discover
# and read via their injected commands.
require "fileutils"
APP = "/app"

ctrl = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Room 7 (Command Injection). Network diagnostics tool: the `host` parameter
  # is interpolated into a shell command with no sanitisation (the vulnerability).
  class NetcheckController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_around_action :switch_locale, raise: false

    def check
      host = params[:host].to_s
      host = "localhost" if host.strip.empty?
      out = `cd /app/tmp && getent hosts #{host} 2>&1`   # UNSANITISED shell interpolation
      render plain: "$ getent hosts #{host}\n#{out}"
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/netcheck_controller.rb"), ctrl)
puts "wrote netcheck_controller.rb"

# The flag lives in the diagnostics tool's working dir (/app/tmp), discoverable
# and readable once the attacker achieves command execution.
FileUtils.mkdir_p("#{APP}/tmp")
File.write("#{APP}/tmp/cmdinj_flag.txt", "CoLab{CMD_INJECT_2026}\n")
puts "planted #{APP}/tmp/cmdinj_flag.txt"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
if src.include?("api/netcheck")
  puts "route already present"
else
  marker = "Rails.application.routes.draw do\n"
  inject = marker + "  get 'api/netcheck', to: 'netcheck#check'  # CTF Room 7 (command injection)\n"
  File.write(routes, src.sub(marker, inject))
  puts "inserted api/netcheck route"
end
