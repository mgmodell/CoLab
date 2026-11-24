# CoLab CTF - Box 3 (Reflected XSS) uses a server-rendered reflection endpoint
# (/content/preview) + an instructor-only secret (/instructor/xss_flag), both
# embedded by patch_xss.rb. No malicious data needs to live in the DB, so this
# just restores the submission we had used while prototyping the (React-neutralized)
# stored approach, leaving the app clean. Idempotent.
s = Submission.find_by(id: 2)
if s && s.sub_text.to_s.include?("srcdoc") || (s && s.sub_text.to_s.include?("onerror"))
  s.update_column(:sub_text, "Reflection: our team divided the work early and checked in twice a week. - submission text")
  puts "restored submission 2 sub_text to benign content"
else
  puts "submission 2 already clean"
end
