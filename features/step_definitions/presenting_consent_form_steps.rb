# frozen_string_literal: true

require 'chronic'
require 'forgery'

Given /^there is a global consent form$/ do
  @consent_form = ConsentForm.new(
    name: Forgery::Name.location,
    user: User.find(1)
  )
end

Given /^the course has a consent form$/ do
  @consent_form = ConsentForm.new(
    user: User.find(1),
    name: Forgery::Name.location
  )
  @consent_form.save
  puts @consent_form.errors.full_messages unless @consent_form.errors.blank?
  course - @project.course
  course.consent_form = @consent_form
  course.save
  puts course.errors.full_messages unless course.errors.blank?
end

Then /^user should see a consent form listed for the open project$/ do
  page.should have_content 'Research Consent Form'
  page.should have_content @project.name
end

When /^user clicks the link to the project, they will be presented with the consent form$/ do
  click_link_or_button @project.name
  page.should have_content 'Please review the document below.'
end

Given /^the user is the "(.*?)" user in the group$/ do |ordinal|
  @user = if ordinal == 'last'
            @group.users.last
          elsif ordinal == 'first'
            @group.users[0]
          else
            @group.users.sample
          end
end

Given /^the consent form "(.*?)" been presented to the user$/ do |has_or_has_not|
  presented = has_or_has_not == 'has'
  consent_log = ConsentLog.create(presented: presented,
                                  user_id: @user.id,
                                  consent_form_id: @consent_form.id)
end

Then /^user will be presented with the installment form$/ do
  page.should have_content 'Your weekly installment'
  page.should have_content @project.name
end

Then /^user should not see a consent form listed for the open project$/ do
  page.should have_content 'Not for Research'
end

When /^the user visits the index$/ do
  visit '/'
end

Given /^the consent form started "([^"]*)" and ends "([^"]*)"$/ do |start_date, end_date|
  @consent_form.start_date = Chronic.parse(start_date)
  @consent_form.end_date = end_date.casecmp('null').zero? ? nil : Chronic.parse(end_date)
  @consent_form.save
  puts @consent_form.errors.full_messages unless @consent_form.errors.empty?
end

Given /^the consent form "([^"]*)" active$/ do |is_active|
  @consent_form.active = is_active == 'is'
  @consent_form.save
  puts @consent_form.errors.full_messages unless @consent_form.errors.empty?
end
