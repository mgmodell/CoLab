Given /^the email queue is empty$/ do
  ActionMailer::Base.deliveries = []
  ActionMailer::Base.deliveries.count.should eq 0
end

When /^the system emails stragglers$/ do
  Assessment.send_reminder_emails
end

Then /^an email will be sent to each member of the group$/ do
  ows = @user.waiting_tasks
  g = ows[0][0]
  group_count = g.users.count
  ActionMailer::Base.deliveries.count.should eq group_count
end

Then /^an email will be sent to each member of the group but one$/ do
  ows = @user.waiting_tasks
  g = ows[0][0]
  group_count_minus_one = g.users.count - 1
  ActionMailer::Base.deliveries.count.should eq group_count_minus_one
end

Then /^no emails will be sent$/ do
  ActionMailer::Base.deliveries.count.should eq 0
end
