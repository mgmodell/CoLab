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

  test 'reminder sweep queues ended assessment grades' do
    assessment = assessments( :one )
    assessment_query = relation_yielding( assessment )
    experience_query = relation_yielding

    assert_enqueued_with job: LtiGradePushJob do
      Assessment.stub( :joins, assessment_query ) do
        Experience.stub( :where, experience_query ) do
          LtiGradePushJob.enqueue_ended_period_grades
        end
      end
    end
  end

  test 'reminder sweep queues ended experience grades' do
    assessment_query = relation_yielding
    experience = experiences( :one )
    experience_query = relation_yielding( experience )

    assert_enqueued_with job: LtiGradePushJob do
      Assessment.stub( :joins, assessment_query ) do
        Experience.stub( :where, experience_query ) do
          LtiGradePushJob.enqueue_ended_period_grades
        end
      end
    end
  end

  test 'assignment score changes enqueue a grade push' do
    user = users( :one )
    rubric = Rubric.new( name: 'Test rubric' )
    rubric.save!( validate: false )
    assignment = Assignment.new(
      course: courses( :one ),
      rubric:,
      start_date: Time.current,
      end_date: 1.day.from_now
    )
    assignment.save!( validate: false )
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

  test 'assignment grade push submits the recorded score to linked resource links' do
    submission = Submission.new(
      assignment_id: 42,
      user_id: 24,
      recorded_score: 85,
      updated_at: Time.current
    )
    received_score = nil
    resource_link = Object.new
    resource_link.define_singleton_method( :push_score ) { | **score | received_score = score }

    LtiResourceLink.stub( :where, relation_yielding( resource_link ) ) do
      LtiGradePushJob.perform_now( submission )
    end

    assert_equal(
      { user_id: '24', score_given: 85, score_maximum: 100, timestamp: submission.updated_at },
      received_score
    )
  end

  private

  def relation_yielding( *records )
    relation = Object.new
    relation.define_singleton_method( :where ) { | * | self }
    relation.define_singleton_method( :find_each ) { | &block | records.each( &block ) }
    relation
  end
end
