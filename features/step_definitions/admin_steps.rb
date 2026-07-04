# frozen_string_literal: true

Given( /^there is a course$/ ) do
  @course = School.find( 1 ).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within( range: 100..5000 ),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name( true ).should_not be_nil
  @course.get_name( true ).length.should be > 0
end

Then( /^the user sets the project to the course's project$/ ) do
  if has_select? 'Source of groups', visible: :all
    page.select( @project.name, from: 'Source of groups', visible: :all )
  else
    find( 'div', id: /bingo_game_project_id/ ).click
    find( 'li', text: @project.name ).click

  end
end

Given('the course is in {string} school') do |string|
  school = School.find_by(name: string)
  school = school.nil? ? School.create(name: string) : school
  @course.school = school
  @course.save
end

Then('the user sees {int} students visible') do |user_count|
  # byebug unless has_text?( "#{user_count} active users" )
  has_text?( "#{user_count} active users" ).should be true
end

Then('the user {string} see an active {string} button') do |does_or_does_not, button_name|
  merge_buttons = all(:link_or_button, button_name, visible: :all)
  if 'does' == does_or_does_not
    merge_buttons.first.should_not be_disabled
  else
    merge_buttons.first.should be_disabled unless merge_buttons.empty?
  end
end

Then ('the course participants are in the same school as the course') do
  @course.users.each do |u|
    u.school = @course.school
    u.save
  end
end

Then('the user searches for a user by {string} {string} from {string}') do |search_type, search_field, user_type|
  ack_messages
  @search_user = nil
  case user_type
  when 'student'
    @search_user = Roster.students.sample.user
  when 'their course'
    @search_user = @user.courses.sample.rosters.sample.user
  when 'their school'
    @search_user = @user.school.users.sample
  when 'any school'
    @search_user = User.all.sample
  when 'another school'
    @search_user = User.where.not(school: @user.school).sample
  when 'self'
    @search_user = @user
  else 
    pending
  end

  @search_user.should_not be_nil

  search_term = ''
  case search_field
  when 'given name'
    search_term = @search_user.first_name
  when 'family name'
    search_term = @search_user.last_name
  when 'anonymized family name'
    search_term = @search_user.anon_last_name
  when 'email'
    search_term = @search_user.email
  else
    pending
  end
  search_term = search_term[1..-1] unless 'complete' == search_type
  fill_in 'Name and/or email', with: search_term
  click_link_or_button 'Search'
end

Then('the user {string} found') do |is_or_is_not|
  wait_for_render
  search_xpath = %{//td[text()='#{@search_user.first_name}']/following-sibling::td[text()='#{@search_user.last_name}']/following-sibling::td[text()='#{@search_user.email}']}
  has_xpath?( search_xpath ).should be true if 'is' == is_or_is_not
end

Then('the user views the user') do
  row = find( :xpath, %{//td[text()='#{@search_user.first_name}']} )
            .sibling( :xpath, %{//td[text()='#{@search_user.last_name}']} )
            .sibling( :xpath, %{//td[text()='#{@search_user.email}']} )
  row.click
end

Then('the user sees {int} course listed') do |int|
  wait_for_render
  has_text?( "Courses (#{int}):" ).should be true
end

Then('the user closes the user view') do
  find( :xpath, "//div[@role='dialog']//button[@data-pc-section='closebutton']" ).click
end

Then('there is a user who is a researcher') do
  @user = User.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    email: Faker::Internet.email,
    researcher: true,
    welcomed: true,
    school: School.first,
    timezone: 'UTC'
  )
  @user.skip_confirmation!
  @user.save
  log @user.errors.full_messages if @user.errors.present?
end

Then('the user sees anonymized data with no roles') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user clicks the {string} button on the user') do |button_name|
  click_button( button_name, match: :first )
end

Then('the user searches for deleted user') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the found user is a {string}') do |role|
  case role
  when 'researcher'
    @search_user.researcher.should be true
  when 'instructor'
    @search_user.instructor.should be true
  when 'admin'
    @search_user.admin.should be true
  else
    pending # Write code here that turns the phrase above into concrete actions
  end
end

Given( 'select user {int} from {string}' ) do |index, population|
  @selected_users ||= {}
  case population
  when 'user course'
    @selected_users[ index ] = @user.courses.sample.rosters.map{ |r| r.user }.sample
  when 'otherschool'
    school = School.where.not( id: @user.school.id ).sample
    @selected_users[ index ] = school.users.sample
  else
    pending # Write code here that turns the phrase above into concrete actions
  end

end

Then('switch to user {int}') do |int|
# Then('switch to user {float}') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user enters the email address for user {int} and user {int}') do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user searches for user {int} by email') do |int|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the user sees {int} {string}') do |int, string|
  pending # Write code here that turns the phrase above into concrete actions
end