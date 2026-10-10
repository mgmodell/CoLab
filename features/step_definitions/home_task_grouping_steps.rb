# frozen_string_literal: true

When( 'the user selects task grouping {string}' ) do | grouping |
  wait_for_render
  find( :xpath, "//*[@id='task-group-by']/ancestor::div[contains(@class,'p-dropdown')]", visible: :any ).click
  find( :xpath, "//li[@role='option' and normalize-space(.)=#{xpath_literal(grouping)}]" ).click
  wait_for_render
end

Then( 'the task group header contains {string}' ) do | text |
  find( :xpath, "//tr[contains(@class,'p-rowgroup-header')]" ).text.should include( text )
end

Then( 'the task group header contains the course name' ) do
  find( :xpath, "//tr[contains(@class,'p-rowgroup-header')]" ).text.should include( @course.get_name( false ) )
end

Then( 'the task group header contains the close-date week' ) do
  week_start = @experience.next_deadline.in_time_zone( @course.timezone ).to_date.beginning_of_week.iso8601
  find( :xpath, "//tr[contains(@class,'p-rowgroup-header')]" ).text.should include( week_start )
end

When( 'the user expands or collapses the task group {string}' ) do | group_name |
  header = find( :xpath,
                 "//tr[contains(@class,'p-rowgroup-header') and contains(.,#{xpath_literal(group_name)})]" )
  header.find( 'button' ).click
  wait_for_render
end

Then( 'the experience task is hidden' ) do
  page.should have_no_css( 'tbody tr', text: @experience.name )
end

Then( 'the experience task is visible' ) do
  page.should have_css( 'tbody tr', text: @experience.name )
end
