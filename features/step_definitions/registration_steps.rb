Then /^the user will see the assessment listing page$/ do
  page.should have_content "Your Assessments"
end

Then /^the user will see a consent request$/ do

  page.should have_content "May we user your data for research?"
end

When /^the user "(.*?)" provide consent$/ do |does_or_does_not|
  consent = does_or_does_not == "does"
  if consent
    check('consent_log[accepted]')
  end
  click_button "Respond to Consent Form"
end

Then /^the user will see a request for demographics$/ do
  page.should have_content( "Edit your profile.")
end


Given /^a user has signed up$/ do
  @user = User.make
  @user.confirm!
  @user.save
end

When /^the user "(.*?)" fill in demographics data$/ do |does_or_does_not|
  give_demographics = does_or_does_not == "does"
  if give_demographics
    page.select( "Male", :from => "user_gender_id" )
    page.select( "18-20", :from => "user_age_range_id" )
    page.select( "some", :from => "user_group_project_count_id" )
    page.select( "positive", :from => "user_group_project_attitude_id" )
    page.select( "Belize", :from => "user_home_country" )
    page.fill_in( "user_group_project_dislikes", :with => Forgery::Basic.text( :at_most => 250, :at_least => 15 ) )
    page.fill_in( "user_group_project_likes", :with => Forgery::Basic.text( :at_most => 250, :at_least => 15 ) )
    page.fill_in( "user_current_password", :with => "password" )
  end
  click_button "Update User"
end
