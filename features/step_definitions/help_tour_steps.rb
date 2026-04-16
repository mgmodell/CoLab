# frozen_string_literal: true

Then( 'the user clicks the help button' ) do
  wait_for_render
  find( :id, 'help-menu-button' ).click
end

Then( 'the user should see a tour popover' ) do
  wait_for_render
  page.should have_css( '.driver-popover' )
end

Then( 'the tour popover title should contain {string}' ) do | text |
  find( '.driver-popover-title' ).text.should include( text )
end

Then( 'the tour popover description should contain {string}' ) do | text |
  find( '.driver-popover-description' ).text.should include( text )
end

Then( 'the user closes the tour' ) do
  find( '.driver-popover-close-btn' ).click
  page.should have_no_css( '.driver-popover' )
end
