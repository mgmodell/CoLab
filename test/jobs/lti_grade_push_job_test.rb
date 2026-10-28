# frozen_string_literal: true

require 'test_helper'

class LtiGradePushJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'candidate review completion enqueues a grade push' do
    bingo_game = bingo_games( :one )
    bingo_game.reviewed = true

    assert_enqueued_with job: LtiGradePushJob do
      bingo_game.save!( validate: false )
    end
  end

  test 'assessment end date schedules a project grade push' do
    assessment = assessments( :one )
    assessment.project = projects( :one )
    assessment.end_date = 1.day.from_now

    assert_enqueued_with job: LtiGradePushJob do
      assessment.save!( validate: false )
    end
  end

  test 'experience end date schedules a grade push' do
    experience = experiences( :one )
    experience.course = courses( :one )
    experience.end_date = 1.day.from_now

    assert_enqueued_with job: LtiGradePushJob do
      experience.save!( validate: false )
    end
  end

  test 'assignment score changes enqueue a grade push' do
    user = users( :one )
    assignment = Assignment.new(
      course: courses( :one ),
      start_date: Time.current,
      end_date: 1.day.from_now
    )
    assignment.save!( validate: false )
    rubric = Rubric.new( name: 'Test rubric' )
    rubric.save!( validate: false )
    submission = Submission.new(
      assignment:,
      user:,
      creator: user,
      rubric:,
      submitted: Time.current,
      sub_text: 'Submitted work'
    )
    submission.save!( validate: false )

    assert_enqueued_with job: LtiGradePushJob do
      submission.update!( recorded_score: 85 )
    end
  end
end
