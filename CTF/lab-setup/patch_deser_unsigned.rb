# CoLab CTF - embed Room 9 (Insecure Deserialization: UNSIGNED Marshal sink).
# Idempotent; run in the app container:  ruby /tmp/patch_deser_unsigned.rb  (then
# restart the app).
#
# Adds a "restore saved view" endpoint that base64-decodes a user-supplied `state`
# parameter and Marshal.loads it with NO signature/verification (the bug). Ruby
# runs Class._load during Marshal.load, so a crafted serialized object is remote
# code execution. NOTHING is handed to the player: there is no signing key and no
# staged exploit - they build the gadget themselves with the ruby that ships in
# the toolkit, send it, and exfiltrate a server-only secret via CoLab's public dir.
require "fileutils"
APP = "/app"

# Gadget class planted in the app so Marshal.load reliably instantiates it and
# runs the carried command (the textbook Marshal-RCE primitive).
gadget = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Room 9 (Insecure Deserialization) gadget. Ruby invokes Class._load during
  # Marshal.load for objects dumped via _dump - so deserializing an instance runs
  # the embedded command.
  class CtfDeserGadget
    def initialize(cmd = nil); @cmd = cmd; end
    def _dump(_level); @cmd.to_s; end
    def self._load(cmd)
      `#{cmd}` rescue nil
      allocate
    end
  end
RUBY
File.write(File.join(APP, "app/models/ctf_deser_gadget.rb"), gadget)
puts "wrote ctf_deser_gadget.rb"

# Server-only secret the RCE exfiltrates (not under public/ - only code execution
# on the server can read it).
FileUtils.mkdir_p("#{APP}/tmp")
File.write("#{APP}/tmp/colab_secret_flag", "CoLab{DESER_MARSHAL_2026}\n")
puts "planted #{APP}/tmp/colab_secret_flag"

# The unsigned deserialization sink.
ctrl = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Room 9 (Insecure Deserialization). "Restore saved view" accepts a base64
  # `state` blob and Marshal.loads it with NO signature check (the vulnerability).
  class PrefsController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :verify_authenticity_token, raise: false
    skip_around_action :switch_locale, raise: false

    def restore
      blob = params[:state].to_s
      pad  = "=" * ((4 - blob.length % 4) % 4)
      raw  = Base64.urlsafe_decode64(blob + pad) rescue Base64.decode64(blob)
      obj  = Marshal.load(raw)   # UNSIGNED deserialization of user input (the bug)
      render json: { restored: true, view: obj.class.to_s }
    rescue => e
      render json: { restored: false, error: e.class.to_s }, status: :ok
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/prefs_controller.rb"), ctrl)
puts "wrote prefs_controller.rb"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
if src.include?("api/prefs/restore")
  puts "route already present"
else
  marker = "Rails.application.routes.draw do\n"
  inject = marker + "  get 'api/prefs/restore', to: 'prefs#restore', defaults: { format: 'json' }  # CTF Room 9 (unsigned deserialization)\n"
  File.write(routes, src.sub(marker, inject))
  puts "inserted api/prefs/restore route"
end
