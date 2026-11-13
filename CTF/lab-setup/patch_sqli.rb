# CoLab CTF - embed Room 2 (SQL Injection: login bypass). Idempotent; run in the
# app container:  ruby /tmp/patch_sqli.rb   (seed the table with seed_sqli.rb via
# rails runner, then restart the app).
#
# Adds a reporting-portal login that concatenates the username/password straight
# into a SQL string (the bug) - the classic authentication-bypass SQL injection.
# The admin row's `secret` column holds the flag, reachable by bypassing the login
# ('  admin'-- '  or  ' OR '1'='1'-- ) or by a UNION on the secrets column.
# NOTHING is handed to the player - they inject through the real login form.
require "fileutils"
APP = "/app"

ctrl = <<~'RUBY'
  # frozen_string_literal: true
  # CTF Room 2 (SQL Injection). Portal login builds its query by string-
  # concatenating user input - classic auth-bypass / UNION SQLi. Error-based: the
  # DB error is echoed to the client (itself an information-disclosure smell).
  class PortalController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :verify_authenticity_token, raise: false
    skip_around_action :switch_locale, raise: false

    def login
      u = params[:username].to_s
      p = params[:password].to_s
      sql = "SELECT username, role, secret FROM ctf_portal_users WHERE username = '#{u}' AND password = '#{p}'"
      row = ActiveRecord::Base.connection.exec_query(sql).first
      if row
        render json: { ok: true, welcome: row["username"], role: row["role"], note: row["secret"] }
      else
        render json: { ok: false, error: "invalid credentials" }, status: :unauthorized
      end
    rescue => e
      render json: { ok: false, db_error: e.message.to_s.lines.first.to_s.strip }, status: :internal_server_error
    end
  end
RUBY
File.write(File.join(APP, "app/controllers/portal_controller.rb"), ctrl)
puts "wrote portal_controller.rb"

routes = File.join(APP, "config/routes.rb")
src = File.read(routes)
if src.include?("api/portal/login")
  puts "route already present"
else
  marker = "Rails.application.routes.draw do\n"
  inject = marker + "  post 'api/portal/login', to: 'portal#login', defaults: { format: 'json' }  # CTF Room 2 (SQLi)\n"
  File.write(routes, src.sub(marker, inject))
  puts "inserted api/portal/login route"
end
