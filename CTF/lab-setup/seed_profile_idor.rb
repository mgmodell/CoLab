# Box 1 target accounts for the profile IDOR. student1..student5@idor.local;
# the flag lives in student3's name so the real profile page displays it.
# Idempotent. student=N in the URL maps to studentN@idor.local.
ActionMailer::Base.perform_deliveries = false
FLAG = "CoLab{IDOR_RECORDS_2026}"
lang = Language.find_by(code: "en") || Language.create!(code: "en", name_en: "English: American", translated: true)

roster = [
  ["student1@idor.local", "Jordan", "Lee"],       # the player's OWN account (student=1)
  ["student2@idor.local", "Taylor", "Kim"],
  ["student3@idor.local", FLAG,     "STUDENT-RECORD"],  # <- flag account (student=3)
  ["student4@idor.local", "Morgan", "Diaz"],
  ["student5@idor.local", "Riley",  "Nguyen"],
]

roster.each do |email, fn, ln|
  u = (User.joins(:emails).find_by(emails: { email: email }) rescue nil)
  nr = u.nil?; u ||= User.new
  u.email = email
  if nr; u.password = "Password1"; u.password_confirmation = "Password1"; end
  u.first_name = fn; u.last_name = ln
  u.timezone = "UTC" if u.respond_to?(:timezone) && u.timezone.blank?
  u.welcomed = true  if u.respond_to?(:welcomed=)
  u.language = lang  if u.respond_to?(:language=)
  u.skip_confirmation! if u.respond_to?(:skip_confirmation!)
  u.save!
  u.emails.each { |e| e.update_column(:confirmed_at, Time.current) if e.respond_to?(:confirmed_at) && e.confirmed_at.nil? }
end

puts "seeded profile-IDOR accounts (login studentN@idor.local / Password1):"
(1..5).each do |i|
  u = User.joins(:emails).find_by(emails: { email: "student#{i}@idor.local" })
  puts "  student=#{i} -> id=#{u.id}  #{u.first_name} #{u.last_name}"
end
