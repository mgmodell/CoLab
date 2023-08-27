# frozen_string_literal: true

require 'faker'

When(/^the project is activated$/) do
  @project.active = true
  @project.save
  log @project.errors.full_messages if @project.errors.present?
end

Then(/^there should be (\d+) project save errors$/) do |expected_error_count|
  if @project.errors.count > expected_error_count.to_i
    log @project.errors.count
    log @project.errors.full_messages
  end
  @project.errors.count.should eq expected_error_count.to_i
end

Given(/^an additional user is in each group of the project$/) do
  user = User.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    email: Faker::Internet.email,
    timezone: 'UTC',
    theme_id: 1
  )
  user.skip_confirmation!
  user.save
  user.name(true).should_not be ', '
  log user.errors.full_messages if user.errors.present?
  @project.groups.each do |group|
    group.users << user
  end
  @project.save
  log @project.errors.full_messages if @project.errors.present?
end

Then(/^there should be an error if I try to modify an project field$/) do
  @project.start_date = @project.start_date + 1
  @project.save
  log @project.errors.full_messages if @project.errors.present?
  @project.errors.count.should be > 0
end

Then(/^there should be an error if I try to modify a group that is part of an active project$/) do
  group = @project.groups.last
  user = group.users.last
  group.users.delete(user)
  group.save
  log group.errors.full_messages if group.errors.present?
  group.errors.count.should be > 0
end

Given(/^the factor pack is set to "([^"]*)"$/) do |pack_name|
  @project.factor_pack = FactorPack.where(name_en: pack_name).take
  @project.save
  log @project.errors.full_messages if @project.errors.present?
end
