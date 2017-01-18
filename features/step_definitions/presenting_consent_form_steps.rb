Given /^the project has a consent form$/ do
  consent_form = ConsentForm.make
  consent_form.save
  @project.consent_form = consent_form
  @project.save
end

Then /^user should see a consent form listed for the open project$/ do
  page.should have_content "Research Consent Form"
  page.should have_content @project.name
end

When /^user clicks the link to the project, they will be presented with the consent form$/ do
  click_link_or_button @project.name
  page.should have_content "Please review the document below."
end

Given /^the user is the "(.*?)" user$/ do |ordinal|
  if ordinal == "last"
    @user = @group.users.last
  elsif ordinal == "first"
    @user = @group.users[ 0 ]
  else
    @user = @group.users[ 1 ]
  end
end

Given /^the consent form "(.*?)" been presented to the user$/ do |has_or_has_not|
  presented = has_or_has_not == "has"
  consent_form = @project.consent_form
  consent_log = ConsentLog.create( :presented => presented,
                                  :user_id => @user.id,
                                  :consent_form_id => consent_form.id )

end

Then /^user will be presented with the installment form$/ do
  page.should have_content "Your weekly installment"
  page.should have_content @assessment.name
end

Then /^user should not see a consent form listed for the open assessment$/ do
  page.should have_content "Not for Research"
end

When /^the user visits the index$/ do
  visit "/"
end

