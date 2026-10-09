# frozen_string_literal: true

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test 'next assessment opening is the next scheduled start day' do
    project = Project.new(
      start_date: Time.zone.parse( '2026-10-01' ),
      end_date: Time.zone.parse( '2026-12-01' ),
      start_dow: 1
    )
    project.stub( :course_timezone, 'UTC' ) do
      travel_to Time.zone.parse( '2026-10-09 12:00' ) do
        assert_equal Time.zone.parse( '2026-10-12 00:00' ),
                     project.next_assessment_opening
      end
    end
  end

  test 'next assessment opening is nil when no scheduled opening remains' do
    project = Project.new(
      start_date: Time.zone.parse( '2026-10-01' ),
      end_date: Time.zone.parse( '2026-10-10' ),
      start_dow: 1
    )
    project.stub( :course_timezone, 'UTC' ) do
      travel_to Time.zone.parse( '2026-10-09 12:00' ) do
        assert_nil project.next_assessment_opening
      end
    end
  end

  test 'task data links to student project information' do
    group = Object.new
    group.define_singleton_method( :get_name ) { |_anonymous| 'Team A' }
    course = Object.new
    course.define_singleton_method( :get_name ) { |_anonymous| 'Course A' }
    project = Project.new( id: 12, name: 'Project A' )

    project.stub( :group_for_user, group ) do
      project.stub( :course, course ) do
        project.stub( :next_assessment_opening, nil ) do
          data = project.task_data( current_user: Object.new )

          assert_equal :project, data[:type]
          assert_equal 'Project A', data[:name]
          assert_equal 'Team A', data[:group_name]
          assert_equal 'Course A', data[:course_name]
          assert_equal 'project/12', data[:link]
        end
      end
    end
  end
end
