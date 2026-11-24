# CoLab CTF - Box 6 (Broken Access Control: mass-assignment privilege escalation).
# A plain student can self-promote to "researcher" because CoLab permits the
# `researcher` attribute in account_update strong-params (see
# ApplicationController#configure_permitted_parameters). is_researcher? just reads
# that column, and check_viewer lets admin/instructor/researcher through. So a
# student PUTs {researcher:true} to /auth and then can open staff-only course
# views (check_viewer) they were blocked from as a student.
# We plant: (1) a plain student account, (2) a staff course whose description
# holds the flag - visible only once the attacker is a viewer. Idempotent.
ActionMailer::Base.perform_deliveries = false
FLAG = "CoLab{BAC_RESEARCHER_2026}"
lang = Language.find_by(code: "en") || Language.create!(code: "en", name_en: "English: American", translated: true)

# (1) plain student - NOT researcher/instructor/admin
email = "student-bac@colab.test"
u = (User.joins(:emails).find_by(emails: { email: email }) rescue nil)
nr = u.nil?; u ||= User.new
u.email = email
if nr; u.password = "Password1"; u.password_confirmation = "Password1"; end
u.first_name = "Sam"; u.last_name = "Student"
u.researcher = false if u.respond_to?(:researcher=)
u.instructor = false if u.respond_to?(:instructor=)
u.admin      = false if u.respond_to?(:admin=)
u.timezone = "UTC" if u.respond_to?(:timezone) && u.timezone.blank?
u.welcomed = true  if u.respond_to?(:welcomed=)
u.language = lang  if u.respond_to?(:language=)
u.skip_confirmation! if u.respond_to?(:skip_confirmation!)
u.save!
u.update_columns(researcher: false, instructor: false, admin: false)
u.emails.each { |e| e.update_column(:confirmed_at, Time.current) if e.respond_to?(:confirmed_at) && e.confirmed_at.nil? }

# (2) staff-only course whose description carries the flag (viewer-gated via show)
school = (School.first || School.create!(name: "CTF School"))
c = Course.find_by(number: "STAFF-RSRCH-9000")
c ||= Course.new(number: "STAFF-RSRCH-9000")
c.name        = "STAFF - Research Data Vault"
c.description = "Restricted staff research dashboard. Researcher access key: #{FLAG}"
c.school    = school if c.respond_to?(:school=)
c.timezone  = "UTC" if c.respond_to?(:timezone=) && c.timezone.blank?
c.start_date = Date.today - 30 if c.respond_to?(:start_date=) && c.start_date.blank?
c.end_date   = Date.today + 30 if c.respond_to?(:end_date=) && c.end_date.blank?
c.save!

# hygiene: drop the stale records-canary (old box-1 roster version) from all rosters
stale = (User.joins(:emails).find_by(emails: { email: "records-canary@colab.test" }) rescue nil)
if stale
  Roster.where(user_id: stale.id).destroy_all
  stale.update_columns(first_name: "Archived", last_name: "User")
end
# and the earlier roster-version victim if present
old = (User.joins(:emails).find_by(emails: { email: "bac-victim@colab.test" }) rescue nil)
Roster.where(user_id: old.id).destroy_all if old

puts "BAC ready: student=#{u.id} (#{email}/Password1, researcher=#{u.researcher.inspect}); staff course=#{c.id} '#{c.name}'"
puts "Chain: student blocked from GET /api-backend/courses/#{c.id}.json -> PUT /auth {researcher:true} -> can read it -> flag in description."
