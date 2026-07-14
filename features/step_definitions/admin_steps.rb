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
  wait_for_render
  has_text?( "#{user_count} active users" ).should be true
end

Then('the user {string} see an active {string} button') do |does_or_does_not, button_name|
  wait_for_render
  search_buttons = all(:link_or_button, button_name, visible: :all)
  if 'does' == does_or_does_not
    search_buttons.first.should_not be_disabled
  else
    search_buttons.first.should be_disabled unless search_buttons.empty?
  end
end

Then ('the course participants are in the same school as the course') do
  @course.users.each do |u|
    u.school = @course.school
    u.save
  end
end

Then( 'the user searches for a user by {string} {string} from {string}' ) do |search_type, search_field, user_type|
  ack_messages
  click_link_or_button 'Clear'
  case user_type
  when 'student'
    @search_user = Roster.joins(:user).students.where( users: { active: true } ).sample.user
  when 'their course'
    @search_user = @user.courses.sample.rosters.sample.user
  when 'their school'
    @search_user = @user.school.users.where( active: true ).sample
  when 'any school'
    @search_user = User.where( active: true ).sample
  when 'another school'
    @search_user = User.where.not(school: @user.school).where( active: true ).sample
  when 'self'
    @search_user = @user
  when 'admin'
    @search_user = User.where( admin: true ).where.not( id: @user.id ).sample
  when 'researcher'
    @search_user = User.where( researcher: true ).where.not(id: @user.id ).sample
  when 'previous search'
    # No Operation, just use the previous search user
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
  wait_for_render
end

Then('the user {string} found') do |is_or_is_not|
  wait_for_render
  search_xpath = %Q{//td[text()="#{@search_user.first_name}"]/following-sibling::td[text()="#{@search_user.last_name}"]}
  search_xpath += %Q{/following-sibling::td[text()="#{@search_user.email}"]} if @user.is_instructor? || @user.is_admin?
  has_xpath?( search_xpath ).should be 'is' == is_or_is_not
end

Then('the user views the user') do
  search_xpath = %Q{//td[text()="#{@search_user.first_name}"]/following-sibling::td[text()="#{@search_user.last_name}"]}
  search_xpath += %Q{/following-sibling::td[text()="#{@search_user.email}"]} if @user.is_instructor? || @user.is_admin?

  row = find( :xpath, search_xpath )
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
  wait_for_render
  has_text?( @search_user.anon_first_name ).should be true
  has_text?( @search_user.anon_last_name ).should be true
  has_text?( @search_user.email ).should be false
  has_text?( 'Instructor' ).should be false
  has_text?( 'Researcher' ).should be false
  has_text?( 'Admin' ).should be false

  has_text?( %Q{Courses (#{@search_user.courses.size}):} ).should be true
end

Then('there are {int} deleted users') do |deleted_user_count|
  wait_for_render
  User.where( active: false ).count.should be deleted_user_count
end

Then('the user searches for deleted user') do
  ack_messages
  @search_user = User.where( active: false ).sample
  search_term = @search_user.email

  fill_in 'Name and/or email', with: search_term
  click_link_or_button 'Search'
end

Then('the found user {string} a {string}') do |is_or_is_not,role|
  @search_user.reload
  case role.downcase
  when 'researcher'
    @search_user.researcher.should be 'is' == is_or_is_not
  when 'instructor'
    @search_user.instructor.should be 'is' == is_or_is_not
  when 'admin'
    @search_user.admin.should be 'is' == is_or_is_not
  else
    pending # Write code here that turns the phrase above into concrete actions
  end
end

Given( 'select {int} users with {string} shared courses' ) do |count, shared_or_not|
  @selected_users ||= {}
  case shared_or_not
  when 'no'
    user1 = Group.joins( :users ).group( 'user_id' )
                .having( 'count(groups.id) = 1')
                .where( users: {admin: false, instructor: false, researcher: false} )
                .sample.users.sample

    user2 = Roster.where.not( course: user1.courses ).sample.course.users.sample
    @selected_users[ 1 ] = user1
    @selected_users[ 2 ] = user2
  when 'some'
    user1 = User.joins(:courses).where( admin: false, instructor: false, researcher: false )
      .having('count(courses.id) > ?',1).sample
    user2 = user1.courses.sample.rosters.students.sample.user
    @selected_users[ 1 ] = user1
    @selected_users[ 2 ] = user2
  else
    pending # Write code here that turns the phrase above into concrete actions
  end
end
And('the selected users stats are saved') do
  @selected_users[1].should_not be_nil
  @selected_users[2].should_not be_nil
  @selected_users_stats = {
    submissions: @selected_users[1].submissions.size +
           @selected_users[2].submissions.size,
    courses: @selected_users[1].courses.size +
           @selected_users[2].courses.size,
    installments: @selected_users[1].installments.size +
           @selected_users[2].installments.size,
    experiences: @selected_users[1].experiences.size +
           @selected_users[2].experiences.size,
    consent_forms: @selected_users[1].consent_logs.size +
           @selected_users[2].consent_logs.size,
    bingo: @selected_users[1].bingo_games.size +
           @selected_users[2].bingo_games.size
  }
  puts @selected_users_stats.inspect

end

Then('switch to user {int}') do |int|
  @selected_users[0] = @user
  @user = @selected_users[ int ]
end

Then('activate user projects') do
  @user.projects.each do |project|
    project.active = true
    project.save
    @project = project
    puts project.errors.full_messages unless project.errors.empty?
    true.should_be false unless project.errors.empty?
  end
end

Then('the user reverts') do
  @user = @selected_users[0]
end

Then('the user enters the email address for user {int} and user {int}') do |int, int2|
  fill_in 'Predator email', with: @selected_users[1].email
  fill_in 'Prey email', with: @selected_users[2].email
end

Then( 'the user searches for user {int} by email' ) do | index |
  ack_messages
  click_link_or_button 'Clear'
  search_term = @selected_users[index].email
  fill_in 'Name and/or email', with: search_term
  click_link_or_button 'Search'
  wait_for_render
  @search_user = @selected_users[index]
end

Then( 'the user has {int} {string}' ) do | count, activity_type |
  @search_user.reload
  case activity_type.downcase
  when 'experience'
    @search_user.experiences.size.should be count
  when 'bingo'
    @search_user.bingo_games.size.should be count
  else
    pending
  end
end

Then('user {int} {string} viable') do |index, is_or_is_not|
  user = @selected_users[ index ]
  if 'is' == is_or_is_not
    user.active.should be true
    user.emails.size.should be 0
  else
    user.active.should be false
    user.emails.size.should_not be 0
  end
end

And('the merged user shows the combined stats') do
  @search_user.reload
  @selected_users_stats[ :courses ].should eq @search_user.courses.size
  @selected_users_stats[ :installments ].should eq @search_user.installments.size
  @selected_users_stats[ :bingo_games ].should eq @search_user.bingo_games.size
  @selected_users_stats[ :experiences ].should eq @search_user.experiences.size
end 

And('the current experience is from the user') do
  @experience = Experience.joins( course: :rosters ).where( rosters: {user: @user} ).sample
  byebug unless @experience.present?
  @experience.should_not be_nil
end