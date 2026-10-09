# frozen_string_literal: true

Then 'the instructor sees the experience and its student progress' do
  wait_for_render
  row = find( :xpath, "//tr[td[contains(.,#{xpath_literal( @experience.name )})]]" )
  row.text.should include( '0% complete (0/4)' )
  row.click
  wait_for_render
  page.current_path.should eq "/admin/courses/#{@course.id}/experience/#{@experience.id}"

  find( :xpath, "//li[@role='tab' and contains(.,'Student progress')]" ).click
  wait_for_render
  page.should have_content( '0% complete (0 of 4 students)' )
  page.should have_content( 'Incomplete' )
  page.all( :xpath, "//tbody/tr[@role='row']" ).size.should eq 4
end
