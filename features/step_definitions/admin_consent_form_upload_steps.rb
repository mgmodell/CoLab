# frozen_string_literal: true

require 'chronic'
require 'faker'

Given( 'there is a consent form without a PDF' ) do
  @consent_form = ConsentForm.new(
    name: Faker::Nation.nationality,
    user: User.find( 1 ),
    start_date: 1.month.ago,
    end_date: 1.month.from_now,
    active: true
  )
  @consent_form.save!
  log @consent_form.errors.full_messages if @consent_form.errors.present?
end

Then( 'the user opens the consent form for editing' ) do
  wait_for_render
  find( :xpath, "//tbody/tr/td[@role='cell' and contains(.,'#{@consent_form.name}')]" ).click
  wait_for_render
end

Then( 'the user sees the consent form editing page' ) do
  page.should have_css( "input[id='consent_form-name']", wait: 10 )
end

When( 'the admin uploads a PDF for the consent form' ) do
  @pdf_path = Rails.root.join( 'db', 'ConsentForms_consolidated.pdf' )
  # The file input is hidden; attach_file with make_visible: true handles this
  page.attach_file( 'consent_form', @pdf_path.to_s, make_visible: true )
end

Then( 'the new consent form has a PDF stored in Active Storage' ) do
  cf = ConsentForm.last
  cf.pdf.attached?.should be true
end

Then( 'the existing consent form has a PDF stored in Active Storage' ) do
  @consent_form.reload
  @consent_form.pdf.attached?.should be true
end

Then( 'the admin sees the PDF link on the consent form page' ) do
  wait_for_render
  page.should have_css( "a[id='consent_form_pdf_link']", wait: 10 )
end
