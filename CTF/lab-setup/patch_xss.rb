# CoLab CTF - embed Box 3 (Reflected XSS). Idempotent; run in the app container:
#   ruby /tmp/patch_xss.rb
# Adds a real CoLab content-preview endpoint that reflects a submitted `html`
# parameter into a SERVER-RENDERED page WITHOUT escaping (the bug) - a textbook
# reflected XSS. Opened by a logged-in instructor, an attacker-crafted preview
# link runs script in the instructor's session and can read instructor-only data.
# We also add that instructor-only secret (/instructor/xss_flag) so the payload
# has something privileged to steal. Both are rendered by REAL CoLab controllers.
#
# NOTE: CoLab's React SPA auto-escapes output (even CritiqueShell's html-react-parser
# strips inline handlers), so the exploitable sink is this server-rendered reflection.
require "fileutils"
APP = "/app"

flag_ctrl = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Box 3 (XSS) payload target: an instructor-only secret. The reflected-XSS
  # payload, running in a logged-in instructor's browser, reads this - proving the
  # XSS crossed a privilege boundary (a plain student cannot reach it).
  class InstructorSecretController < ApplicationController
    skip_around_action :switch_locale, raise: false
    XSS_FLAG = "CoLab{XSS_STORED_2026}"
    def xss_flag
      unless current_user&.is_instructor? || current_user&.is_admin?
        render json: { error: "instructors only" }, status: :forbidden
        return
      end
      render json: { flag: XSS_FLAG }
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/instructor_secret_controller.rb"), flag_ctrl)
puts "wrote instructor_secret_controller.rb"

preview_ctrl = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Box 3 (Reflected XSS). Renders a submitted `html` parameter into the page
  # WITHOUT output encoding - a reflected XSS sink in a real CoLab controller.
  class ContentPreviewController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_around_action :switch_locale, raise: false
    def show
      raw = params[:html].to_s   # reflected UNescaped (the vulnerability)
      page = <<~HTML
        <!doctype html><html lang="en"><head><meta charset="utf-8">
        <title>CoLab - Content Preview</title></head>
        <body style="font-family:sans-serif;max-width:720px;margin:40px auto">
          <h2>CoLab Content Preview</h2>
          <p>This tool previews submitted rich-text content before posting.</p>
          <hr><div id="preview">#{raw}</div><hr>
          <p style="color:#888;font-size:.9em">Rendered by CoLab content-preview service.</p>
        </body></html>
      HTML
      render html: page.html_safe, layout: false
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/content_preview_controller.rb"), preview_ctrl)
puts "wrote content_preview_controller.rb"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
marker = "Rails.application.routes.draw do\n"
add = ""
add << "  get 'instructor/xss_flag', to: 'instructor_secret#xss_flag', defaults: { format: 'json' }  # CTF Box 3 target\n" unless src.include?("instructor/xss_flag")
add << "  get 'content/preview', to: 'content_preview#show'  # CTF Box 3 (reflected XSS)\n" unless src.include?("content/preview")
if add.empty?
  puts "routes already present"
else
  File.write(routes, src.sub(marker, marker + add))
  puts "inserted routes"
end
