Given /^the email queue is empty$/ do
  ActionMailer::Base.deliveries = []
end

When /^the system emails stragglers$/ do
  Assessment.send_reminder_emails
end

Then /^an email will be sent to each member of the group$/ do
  ows = @user.open_group_reports
  g = ows[ 0 ][ 0 ]
  group_count = g.users.count
  assert ActionMailer::Base.deliveries.count == group_count
end

Then /^an email will be sent to each member of the group but one$/ do
  ows = @user.open_group_reports
  g = ows[ 0 ][ 0 ]
  group_count_minus_one = g.users.count - 1
  assert ActionMailer::Base.deliveries.count == group_count_minus_one
end
