# frozen_string_literal: true
When /^the project is activated$/ do
  @project.active = true
  @project.save
end

Then /^there should be (\d+) project save errors$/ do |expected_error_count|
  if @project.errors.count > expected_error_count.to_i
    puts @project.errors.count
    puts @project.errors.full_messages
  end
  @project.errors.count.should eq expected_error_count.to_i
end

Given /^an additional user is in each group of the project$/ do
  user = User.make
  user.skip_confirmation!
  user.save
  @project.groups.each do |group|
    group.users << user
  end
  @project.save
end

Then /^there should be an error if I try to modify an project field$/ do
  @project.start_date = @project.start_date + 1
  @project.save
  @project.errors.count.should be > 0
end

Then /^there should be an error if I try to modify a group that is part of an active project$/ do
  group = @project.groups.last
  user = group.users.last
  group.users.delete(user)
  group.save
  group.errors.count.should be > 0
end

Given /^the factor pack is set to "([^"]*)"$/ do |pack_name|
  @project.factor_pack = FactorPack.where(name: pack_name).take
  @project.save
end
