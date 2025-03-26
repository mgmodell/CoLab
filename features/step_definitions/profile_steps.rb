# frozen_string_literal: true

Then( /^user opens their profile$/ ) do
  wait_for_render
  find( :id, 'main-menu-button' ).click
  find( :id, 'profile-menu-item' ).click
  page.should have_content( 'Edit your profile' )
  text = "Tell us about yourself, #{@user.first_name} (optional)"
  all( :xpath, "//div[contains(.,'#{text}')]" ).size.should be > 3
  # page.should have_content('Tell us about yourself, ' + @user.first_name)
  find( :xpath, "//div[@data-pc-name='accordion']/div/div/a[contains(.,'Email settings')]" ).click
  @user.emails.each do | email |
    page.should have_content( email.email )
  end
end

Then( /^the user sees the experience in the history$/ ) do
  find( :xpath, "//div[@data-pc-name='tabview']/div/div/ul/li/a[contains(.,'History')]" ).click
  page.should have_content( @experience.get_name( false ) )
end

Then( /^user sees the Bingo! in the history$/ ) do
  find( :xpath, "//div[@data-pc-name='tabview']/div/div/ul/li/a[contains(.,'History')]" ).click
  page.should have_content( @bingo.get_name( false ) )
end

Then( /^user sees the assessed project in the history$/ ) do
  ack_messages
  find( :xpath, "//div[@data-pc-name='tabview']/div/div/ul/li/a[contains(.,'History')]" ).click
  wait_for_render
  page.should have_content( @project.get_name( false ) )
end

Then( /^user sees the assignment in the history$/ ) do
  find( :xpath, "//div[@data-pc-name='tabview']/div/div/ul/li/a[contains(.,'History')]" ).click
  wait_for_render
  page.should have_content( @assignment.get_name( false ) )
end

When( /^the user logs in$/ ) do
  visit '/login'
  wait_for_render

  fill_in 'email', with: @user.email
  fill_in 'password', with: 'password'

  ack_messages
  click_link_or_button 'Log in!'

  wait_for_render
  page.should have_content 'signed in successfully'

  # Blow away the cookies accept
  click_link_or_button 'I understand' if has_content? 'I understand'

  # Set custom time if warranted
  if :rack_test != Capybara.current_driver && !@dest_date.nil?
    fill_in 'newTimeVal', with: @dest_date.to_s
    click_button 'setTimeBtn'
  end
end

Then( 'the user sees a success message' ) do
  page.should have_content( 'uccess' )
end

When( 'the user attempts login with wrong password' ) do
  visit '/login'
  wait_for_render

  fill_in 'email', with: @user.email
  fill_in 'password', with: 'wrong-password'

  ack_messages
  click_link_or_button 'Log in!'
end

Then( 'the user should see a failed login message' ) do
  wait_for_render
  page.should have_content 'Invalid email or password'
end

Then( 'user should see login form' ) do
  wait_for_render
  page.should have_content 'Log in!'
end

Given('there is a registered user') do
  @user = User.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    password: 'password',
    password_confirmation: 'password',
    email: Faker::Internet.email,
    timezone: 'UTC'
  )
  @user.skip_confirmation!
  @user.save
  log @user.errors.full_messages if @user.errors.present?
end

Given('the user {string} confirmed') do |confirmed_status|
  @user.welcomed = confirmed_status == 'is' ? true : false
  @user.save
  log @user.errors.full_messages if @user.errors.present?
end

Then('the user {string} see the {string} page') do |landing_status, page_identifier|
  has_text?( page_identifier ).should be landing_status == 'does'
end

Then('the user sets the {string} to {string}') do |field, value|
  case field
    when 'first name'
      fill_in 'first-name', with: value
      @user.first_name = value
    when 'last name'
      fill_in 'last-name', with: value
      @user.last_name = value
    else
      true.should be false
  end
end

Then('the user saves the profile') do
  click_link_or_button 'Save Profile'
  wait_for_render
  has_text?( 'Profile saved' ).should be true
end

Then('the user sees the name {string} {string}') do |field, value|
  find( :id, field ).value.should eq value
end

Then('the user {string} is {string}') do |field, value|
  case field
    when 'first name'
      find( :id, 'first-name' ).value.should eq value
    when 'last name'
      find( :id, 'last-name' ).value.should eq value
    else
      true.should be false
  end
end