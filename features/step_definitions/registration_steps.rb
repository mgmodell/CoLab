# frozen_string_literal: true

require 'faker'

Then( /^the user will see the task listing page$/ ) do
  page.should have_content 'Your Tasks'
end

Then( /^the user will see a consent request$/ ) do
  page.should have_content 'May we use your data for research?'
end

When( /^the user "(.*?)" provide consent$/ ) do | does_or_does_not |
  consent = 'does' == does_or_does_not
  chkbox = find( :xpath, "//label[contains(.,'I agree')]" )
  chkbox.click if chkbox.checked? != consent
  click_button 'Record my response to this Consent Form'
  wait_for_render
end

Then( /^the user will see a request for demographics$/ ) do
  wait_for_render
  page.should have_content 'Edit your profile'
end

Given( /^a user has signed up$/ ) do
  @user = User.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    email: Faker::Internet.email,
    timezone: 'UTC',
    language: Language.find_by( code: 'en' ),
    school: School.find( 1 ),
    theme_id: 1
  )
  @user.confirm
  @user.save
  log @user.errors.full_messages if @user.errors.present?
  @user.name( true ).should_not be ', '
  @user.name( true ).length.should be > 2
end

When( /^the user "(.*?)" fill in demographics data$/ ) do | does_or_does_not |
  give_demographics = 'does' == does_or_does_not
  if give_demographics
    find( :xpath, "//div[@class='p-accordion-tab']/div/a[contains(.,'Tell us about yourself')]" ).click
    demographics = [
      { label: 'What is your gender?', value: 'Male' },
      { label: 'What are you studying?', value: 'Education' },
      { label: 'What country?', value: 'Belize' },
      { label: 'What language do you speak at home?', value: 'Avestan' }
    ]

    demographics.each do | demo_data |
      label = find( :xpath, "//label[contains(.,'#{demo_data[:label]}')]" )[:for]

      if has_xpath?( "//div[@id='#{label}']" )
        find( :xpath, "//div[@id='#{label}']" ).click
      elsif has_xpath?( "//span[@id='#{label}']/button" )
        find( :xpath, "//span[@id='#{label}']/button" ).click
      else
        true.should be( false ), "No element found for #{label}"
      end
      if has_xpath?( "//li[text()='#{demo_data[:value]}']" )
        find( :xpath, "//li[text()='#{demo_data[:value]}']" ).click
      else
        true.should be( false ), "No element found for #{demo_data[:value]}"
      end
    end

    demographics = [
      { label: 'When did you begin your studies?', value: Date.parse( '11-09-2016' ) },
      { label: 'When were you born?', value: Date.parse( '10-05-1976' ) }
    ]

    demographics.each do | demo_data |
      label = find( :xpath, "//label[contains(.,'#{demo_data[:label]}')]" )[:for]
      find( :xpath, "//input[@id='#{label}']" ).set( demo_data[:value].strftime( '%m/%d/%Y' ) )
    end

    # new_date = Date.parse('10-05-1976')
    # page.find('#user_date_of_birth').set(new_date)
    # new_date = Date.parse('10-09-2016')
    # page.find('#user_date_of_birth').set(new_date)
  end
  click_button 'Save Profile'
  wait_for_render
end

When( /^the new user registers$/ ) do
  find( :xpath, "//ul[@role='tablist']/li/a[contains(.,'Sign up')]" ).click
  email = Faker::Internet.email

  fill_in 'email', with: email
  fill_in 'first_name', with: Faker::Name.first_name
  fill_in 'first_name', with: Faker::Name.last_name

  click_button 'Sign me up!'
  wait_for_render
  email = Email.where( email: )
  expect( email.size ).to eq( 1 )
  @user = email[0].user
  expect( @user ).to be
end

Given '{int} users' do | user_count |
  @users = []
  user_count.to_i.times do
    u = User.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      password: 'password',
      password_confirmation: 'password',
      email: Faker::Internet.email,
      timezone: 'UTC',
      theme_id: 1
    )
    u.skip_confirmation!
    u.save
    @users << u
  end
end

Given( /^a course$/ ) do
  @course = School.find( 1 ).courses.new(
    name: "#{Faker::Company.industry} Course",
    number: Faker::Number.within( range: 100..6000 ),
    timezone: 'UTC',
    start_date: 4.months.ago,
    end_date: 2.months.from_now
  )
  @course.save
  @course.get_name( true ).should_not be_nil
  @course.get_name( true ).length.should be > 0
end

Then( /^the users are added to the course by email address$/ ) do
  email_list = ''
  @users.each do | user |
    email_list += "#{user.email}, "
  end
  @course.add_students_by_email email_list
end

Then( /^the users are added to the course as instructors by email address$/ ) do
  email_list = ''
  @users.each do | user |
    email_list += "#{user.email}, "
  end
  @course.add_instructors_by_email email_list
end

Then( /^the course has (\d+) "([^"]*)" users$/ ) do | user_count, user_status |
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

Then( /^(\d+) emails will have been sent$/ ) do | email_count |
  ActionMailer::Base.deliveries.count.should eq email_count.to_i
end

Given( /^the users are confirmed$/ ) do
  @users.each( &:confirm )
end

Then( /^the user "([^"]*)" enrollment in the course$/ ) do | accept |
  if 'accepts' == accept
    click_link_or_button 'Accept'
  else
    click_link_or_button 'Decline'
  end
  wait_for_render
end

Then( /^the user sees (\d+) invitation$/ ) do | invitation_count |
  check_count = 0
  while check_count < 5 && !all( :xpath, "//*[@id='waiting']" ).empty?
    sleep( 0.01 )
    check_count += 1
  end

  page.should have_content 'confirm that you are actually enrolled in'
  if 1 == invitation_count.to_i
    page.should have_content 'the course listed below'
  else
    page.should have_content "#{invitation_count} courses listed below"
  end
end

Then( /^the user does not see a task listing$/ ) do
  page.should have_no_content 'Your Tasks'
end

Then( 'the user will see no enabled {string} button' ) do | button_name |
  xpath_string = "/button[not(@disabled)]/*[contains(text(),\"#{button_name}\")]/parent::button"
  buttons = find_all( :xpath, xpath_string )
  buttons.size.should eq 0
end
