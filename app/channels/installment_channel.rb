# frozen_string_literal: true

# Broadcasts a notification when any member of a group saves their
# peer-assessment installment.  Clients subscribe with the assessment_id
# and group_id so that all members sharing the same assessment+group
# receive the update in real time.
class InstallmentChannel < ApplicationCable::Channel
  def subscribed
    assessment_id = params[:assessment_id]
    group_id      = params[:group_id]

    if assessment_id.present? && group_id.present?
      stream_from self.class.channel_name( assessment_id, group_id )
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def self.broadcast_submission( installment )
    assessment_id = installment.assessment_id
    group_id      = installment.group_id
    user_name     = installment.user.name( false )

    ActionCable.server.broadcast(
      channel_name( assessment_id, group_id ),
      {
        event:         'installment_saved',
        user_id:       installment.user_id,
        user_name:,
        assessment_id:,
        group_id:
      }
    )
  end

  def self.channel_name( assessment_id, group_id )
    "installment_#{assessment_id}_group_#{group_id}"
  end
end
