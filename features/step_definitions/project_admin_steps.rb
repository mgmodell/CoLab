Then /^the user "([^"]*)" see an Admin button$/  do |admin|
  byebug
  if admin == "does"
    page.should have_content( "Admin" )
  else
    page.should_not have_content( "Admin" )
  end
end

Given /^the user is an admin$/  do
  @user.admin = true
  @user.save
end

Then /^the user clicks the Admin button$/  do
  click_link_or_button "Admin"
end

Then /^the user sees (\d+) course$/  do |course_count|
  page.all( 'tr' ).count == course_count.to_i + 1
end

Given /^the user is the instructor for the course$/  do
  Roster.create( user: @user, course: @course, role: Role.instructor.take )
end

