# CoLab CTF - Box 10 (token forgery -> authentication bypass) target.
# The LTI deep-link flow authenticates whoever the SIGNED dl_token names
# (LtiController#select_content -> ensure_deep_link_user_authenticated: sign_in
# User.find_by(id: dl_token['user_id'])). The token is signed with a key derived
# from secret_key_base; once that key is known, an attacker forges a token naming
# an ADMIN and is logged in as them. For an admin, select_content lists EVERY
# course - so we hide the flag in a course name only an admin ever sees there.
# Idempotent.
ActionMailer::Base.perform_deliveries = false
FLAG = "CoLab{TOKEN_FORGED_2026}"
lang = Language.find_by(code: "en") || Language.create!(code: "en", name_en: "English: American", translated: true)
school = (School.first || School.create!(name: "CTF School"))

admin = User.joins(:emails).find_by(emails: { email: "admin@colab.test" })
raise "admin@colab.test missing - run seed_pentest_users first" unless admin
admin.update_columns(admin: true)

# Sentinel course whose NAME is the flag. Only an admin enumerates all courses
# (select_content -> Course.all); a non-admin's index/select_content never lists
# courses they don't instruct, so this cannot leak into the other rooms.
c = Course.find_by(number: "DL-ADMIN-0001")
c ||= Course.new(number: "DL-ADMIN-0001")
c.name = FLAG
c.description = "Admin-only deep-link sentinel."
c.school = school if c.respond_to?(:school=)
c.timezone = "UTC" if c.respond_to?(:timezone=) && c.timezone.blank?
c.start_date = Date.today - 30 if c.respond_to?(:start_date=) && c.start_date.blank?
c.end_date   = Date.today + 30 if c.respond_to?(:end_date=) && c.end_date.blank?
c.save!

puts "TOKEN target: admin user_id=#{admin.id} (admin@colab.test); sentinel course=#{c.id} name=#{c.name.inspect}"
