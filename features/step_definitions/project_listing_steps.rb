require 'chronic'

Given /^there is a course with an assessed project$/ do
  @course = Course.make
  @course.save
  @project = Project.make
  @project.style = Style.find(1)
  @project.course = @course
  @project.save
end

Given /^the project started "(.*?)" and ends "(.*?)", opened "(.*?)" and closes "(.*?)"$/ do |start_date, end_date, start_dow, end_dow|
  @project.start_date = Chronic.parse(start_date)
  @project.end_date = Chronic.parse(end_date)
  @project.start_dow = Chronic.parse(start_dow).wday
  @project.end_dow = Chronic.parse(end_dow).wday

  @project.save
end

Given /^the project has a group with (\d+) confirmed users$/ do |user_count|
  @group = Group.make
  user_count.to_i.times do
    user = User.make
    user.skip_confirmation!
    @group.users << user
  end
  @project.groups << @group
  @project.save
end

Given /^the project has been activated$/ do
  @project.active = true
  @project.save
end

Then /^the user should see a successful login message$/ do
  page.should have_content 'Signed in successfully.'
end

Then /^user should see (\d+) open project$/ do |open_project_count|
  case open_project_count.to_i
  when 0
    page.should have_content  'You do not currently have any projects.'
  when 1
    page.should have_content  'one project at the moment'
  else
    page.should have_content ( open_project_count + ' projects today')
  end
end

Then /^the user will see the main index page$/ do
  page.should have_content 'Your Projects'
end

Given /^the user "(.*?)" had demographics requested$/ do |with_demographics|
  demographics_requested = with_demographics == 'has'
  @user.welcomed = demographics_requested
  @user.save!
end

When /^the user logs in$/ do
  visit '/'
  fill_in 'user[email]', with: @user.email
  fill_in 'user[password]', with: 'password'

  click_link_or_button 'Log in'
end
