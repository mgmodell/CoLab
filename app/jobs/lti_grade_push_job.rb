# frozen_string_literal: true

class LtiGradePushJob < ApplicationJob
  def perform( record, expected_end_date = nil )
    if record.is_a?( Assessment )
      return if expected_end_date && record.end_date.to_i != expected_end_date
      return if expected_end_date && record.end_date.end_of_day > Time.current

      record = record.project
      expected_end_date = nil
    end
    return if expected_end_date && record.end_date.to_i != expected_end_date
    return if expected_end_date && record.end_date.end_of_day > Time.current

    case record
    when BingoGame, Experience, Project
      return if record.is_a?( BingoGame ) && !record.reviewed?

      push_activity_grades( record )
    when Submission
      push_submission_grade( record )
    end
  end

  private

  def push_activity_grades( activity )
    connection = activity.lti_connection
    return unless connection&.configured?

    activity.lti_grade_scores.each do | score |
      connection.push_score( **score )
    end
  end

  def push_submission_grade( submission )
    return if submission.recorded_score.nil?

    LtiResourceLink.where( assignment_id: submission.assignment_id ).find_each do | resource_link |
      resource_link.push_score(
        user_id: submission.user_id.to_s,
        score_given: submission.recorded_score,
        score_maximum: 100,
        timestamp: submission.updated_at
      )
    end
  end
end
