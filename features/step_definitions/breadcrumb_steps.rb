# frozen_string_literal: true

Then( 'the course listing and item breadcrumb links are separate' ) do
  list_link = find( :css, ".p-breadcrumb a[href='/admin/courses']" )
  list_link.find( 'i' )[ 'title' ].should eq 'Course'

  item_link = find( :css, ".p-breadcrumb a[href='/admin/courses/#{@course.id}']" )
  item_link.find( 'i' )[ 'title' ].should eq 'Item'
end

Then( 'the course activity breadcrumb shows its type icon only' ) do
  activity_path = "/admin/courses/#{@course.id}/project/#{@project.id}"
  visit activity_path
  wait_for_render

  activity_link = find( :css, ".p-breadcrumb a[href='#{activity_path}']" )
  activity_link.all( 'i' ).map { |icon| icon[ 'title' ] }.should eq [ 'Project' ]
end
