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
