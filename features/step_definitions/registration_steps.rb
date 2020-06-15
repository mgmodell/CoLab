# frozen_string_literal: true

require 'forgery'

Then /^the user will see the task listing page$/ do
  page.should have_content 'Your Tasks'
end

Then /^the user will see a consent request$/ do
  page.should have_content 'May we use your data for research?'
end

When /^the user "(.*?)" provide consent$/ do |does_or_does_not|
  consent = does_or_does_not == 'does'
  chkbox = find( :xpath, "//label[contains(.,'I agree')]" )
  if( chkbox.find( :xpath, '//input', visible: :all ).checked? == consent )
    chkbox.click
  end
  click_button 'Record my response to this Consent Form'
end

Then /^the user will see a request for demographics$/ do
  page.should have_content 'Edit your profile'
end

Given /^a user has signed up$/ do
  @user = User.new(
    first_name: Forgery::Name.first_name,
    last_name: Forgery::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    email: Forgery::Internet.email_address,
    timezone: 'UTC',
    language: Language.find_by(code: 'en'),
    school: School.find(1),
    theme_id: 1
  )
  @user.confirm
  @user.save
  puts @user.errors.full_messages if @user.errors.present?
  @user.name(true).should_not be ', '
  @user.name(true).length.should be > 2
end

When /^the user "(.*?)" fill in demographics data$/ do |does_or_does_not|
  give_demographics = does_or_does_not == 'does'
  if give_demographics
    find( :xpath, "//div[@id='demographics']").click

    demographics = [
        {label: 'What is your gender?', value: 'Male'},
        {label: 'What are you studying?', value: 'Education'},
        {label: 'What country and state do you call home?', value: 'Belize'},
        {label: 'What language do you speak at home?', value: 'Avestan'}
      ]

    demographics.each do |demo_data|
      label = find( :xpath, "//label[text()='#{demo_data[:label]}']")[:for]
      find(:xpath, "//div[@id='#{label}']").click
      find(:xpath, "//li[text()='#{demo_data[:value]}']").click
    end
      
    demographics = [
      {label: 'When did you begin your studies?', value: Date.parse('11-09-2016')},
      {label: 'When were you born?', value: Date.parse('10-05-1976')},
    ]

    demographics.each do |demo_data|
      label = find( :xpath, "//label[text()='#{demo_data[:label]}']")[:for]
      find(:xpath, "//input[@id='#{label}']").set( demo_data[:value].strftime( '%m/%d/%Y') )
    end

    #new_date = Date.parse('10-05-1976')
    #page.find('#user_date_of_birth').set(new_date)
    #new_date = Date.parse('10-09-2016')
    #page.find('#user_date_of_birth').set(new_date)
  end
  click_button 'Save Profile'
  count = 0
  while( all( :xpath, '//*[@id="waiting"]' ).size > 0 && count < 3 )
    sleep( 0.1 )
    count+= 1
  end
end

When /^the new user registers$/ do
  click_link_or_button 'Signup'
  email = Forgery::Internet.email_address

  fill_in 'user[email]', with: email
  fill_in 'user[first_name]', with: Forgery::Name.first_name
  fill_in 'user[last_name]', with: Forgery::Name.last_name
  fill_in 'user[password]', with: 'password'

  # These aren't working in capybara
  # page.select('Male', from: 'user_gender_id')
  # page.select('Education', from: 'user_cip_code_id')
  # page.select('Belize', from: 'country')
  # page.select('Avestan', from: 'user_primary_language_id')

  new_date = Date.parse('10-05-1976')
  page.find('#user_date_of_birth').set(new_date)
  new_date = Date.parse('10-09-2016')
  page.find('#user_date_of_birth').set(new_date)
  click_button 'Create my profile'
  email = Email.where email: email
  expect(email.size).to eq(1)
  @user = email[0].user
  expect(@user).to be
end

Given /^(\d+) users$/ do |user_count|
  @users = []
  user_count.to_i.times do
    u = User.new(
      first_name: Forgery::Name.first_name,
      last_name: Forgery::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Forgery::Internet.email_address,
      timezone: 'UTC',
      theme_id: 1
    )
    u.skip_confirmation!
    u.save
    @users << u
  end
end

Given /^a course$/ do
  @course = School.find(1).courses.new(
    name: "#{Forgery::Name.industry} Course",
    number: Forgery::Basic.number,
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name(true).should_not be_nil
  @course.get_name(true).length.should be > 0
end

Then /^the users are added to the course by email address$/ do
  email_list = ''
  @users.each do |user|
    email_list += user.email + ', '
  end
  @course.add_students_by_email email_list
end

Then /^the users are added to the course as instructors by email address$/ do
  email_list = ''
  @users.each do |user|
    email_list += user.email + ', '
  end
  @course.add_instructors_by_email email_list
end

Then /^the course has (\d+) "([^"]*)" users$/ do |user_count, user_status|
  rosters = []
  case user_status.downcase
  when 'invited student'
    rosters = @course.rosters.invited_student
  when 'instructor'
    rosters = @course.rosters.instructor
  when 'enrolled student'
    rosters = @course.rosters.enrolled_student
  when 'requesting student'
    rosters = @course.rosters.requesting_student
  when 'rejected student'
    rosters = @course.rosters.rejected_student
  when 'dropped student'
    rosters = @course.rosters.dropped_student
  when 'declined student'
    rosters = @course.rosters.declined_student
  end
  rosters.size.should eq user_count.to_i
end

Then /^(\d+) emails will have been sent$/  do |email_count|
  ActionMailer::Base.deliveries.count.should eq email_count.to_i
end

Given /^the users are confirmed$/ do
  @users.each(&:confirm)
end

Then /^the user "([^"]*)" enrollment in the course$/ do |accept|
  if accept == 'accepts'
    click_link_or_button 'Accept'
  else
    click_link_or_button 'Decline'
  end
end

Then /^the user sees (\d+) invitation$/ do |invitation_count|
  check_count = 0
  while ( check_count < 5 && all( :xpath, "//*[@id='waiting']" ).size > 0 ) do
    sleep( 0.01)
    check_count+= 1
  end

  page.should have_content 'confirm that you are actually enrolled in'
  if invitation_count.to_i == 1
    page.should have_content 'the course listed below'
  else
    page.should have_content invitation_count.to_s + ' courses listed below'
  end
end

Then /^the user does not see a task listing$/ do
  page.should have_no_content 'Your Tasks'
end
