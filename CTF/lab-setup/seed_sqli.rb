# CoLab CTF - seed Room 2 (SQL Injection) data. Run via:  bin/rails runner seed_sqli.rb
# Creates the reporting-portal users table the SQLi login queries. The admin row's
# `secret` column holds the flag; its password is random (unguessable) so the ONLY
# way in as admin is the injection.
conn = ActiveRecord::Base.connection
conn.execute("CREATE TABLE IF NOT EXISTS ctf_portal_users (id serial primary key, username text, password text, role text, secret text)")
conn.execute("DELETE FROM ctf_portal_users")
conn.execute("INSERT INTO ctf_portal_users (username, password, role, secret) VALUES ('guest','guest','guest','welcome to the CoLab reporting portal')")
pw = SecureRandom.hex(16)
conn.execute("INSERT INTO ctf_portal_users (username, password, role, secret) VALUES ('admin','#{pw}','admin','CoLab{SQLI_LOGIN_2026}')")
puts "seeded ctf_portal_users (admin password random; flag in admin.secret)"
