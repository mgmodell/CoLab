When /^the project is activated$/ do
  @project.active = true
  @project.save
end

Then /^there should be no errors$/ do
  @project.errors.count == 0
end

Given /^an additional user is in each group of the project$/ do
  user = User.make
  user.skip_confirmation!
  user.save
  @project.groups.each do |group|
    group.users << user
  end
end

Then /^there should be one error$/ do
  assert( @project.errors.count == 1 )
end

Then /^there should be an error if I try to modify an project field$/ do
  @project.start_date = @project.start_date + 1
  @project.save
  @project.errors.count > 0
end

Then /^there should be an error if I try to modify a group that is part of an active project$/ do
  group = @project.groups.last
  user = group.users.last
  group.users.delete( user )
  group.save
  assert( group.errors.count > 0 )

end
