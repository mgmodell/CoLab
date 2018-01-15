# frozen_string_literal: true

Then(/^the user should see "([^"]*)"$/) do |page_text|
  page.should have_content page_text
end

Given(/^the course timezone is "([^"]*)"$/) do |timezone|
  @course.timezone = timezone
  @course.save
  puts @course.errors.full_messages unless @course.errors.blank?
end

Given(/^the user timezone is "([^"]*)"$/) do |timezone|
  @user.timezone = timezone
  @user.save
  puts @user.errors.full_messages unless @user.errors.blank?
end
