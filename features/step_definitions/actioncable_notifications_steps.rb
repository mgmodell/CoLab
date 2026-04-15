# frozen_string_literal: true

require 'faker'
require 'action_cable/testing'

# ------------------------------------------------------------------
# Helper: build a minimal installment for @user on the current
# @assessment / @group and save it.  Returns the saved installment.
# ------------------------------------------------------------------
def build_and_save_installment_for( user, assessment, group, project )
  cell_value = Installment::TOTAL_VAL / group.users.size

  installment = Installment.new(
    assessment:,
    user:,
    group:,
    inst_date: Time.current
  )
  group.users.each do | u |
    project.factors.each do | b |
      installment.values.build( factor: b, user: u, value: cell_value )
    end
  end
  installment.save!
  installment
end

# ------------------------------------------------------------------
# Item 6 – InstallmentChannel steps
# ------------------------------------------------------------------

When( /^a group member saves their installment$/ ) do
  assessment = Assessment.where( project: @project ).first
  assert_not_nil assessment, 'Expected an open assessment for the project'

  @submitting_user = @group.users.last
  @saved_installment = build_and_save_installment_for(
    @submitting_user, assessment, @group, @project
  )
  @channel_name = InstallmentChannel.channel_name( assessment.id, @group.id )
end

Then( /^the installment channel should have received a broadcast for the group$/ ) do
  assert broadcasts( @channel_name ).size >= 1,
         "Expected at least one broadcast on #{@channel_name} but found none"
end

Then( /^the installment broadcast payload should contain the submitter's details$/ ) do
  transmissions = broadcasts( @channel_name )
  assert transmissions.size >= 1,
         "Expected at least one broadcast on #{@channel_name} but found none"

  payload = JSON.parse( transmissions.last )

  assert_equal 'installment_saved',       payload['event'],         'event key mismatch'
  assert_equal @submitting_user.id,        payload['user_id'],       'user_id mismatch'
  assert_equal @submitting_user.name( false ), payload['user_name'], 'user_name mismatch'
  assert_equal @saved_installment.assessment_id, payload['assessment_id'], 'assessment_id mismatch'
  assert_equal @group.id,                  payload['group_id'],      'group_id mismatch'
end

Then( /^exactly (\d+) broadcast(?:s)? should be sent to the installment channel$/ ) do | count |
  assert_equal count.to_i, broadcasts( @channel_name ).size,
               "Expected #{count} broadcast(s) on #{@channel_name}"
end

# ------------------------------------------------------------------
# Item 7 – NotificationsChannel steps
# ------------------------------------------------------------------

Then( /^in-app reminder notifications should have been broadcast to each eligible user$/ ) do
  # send_reminder_emails calls NotificationsChannel.broadcast_to_user once
  # per user who has not yet been emailed today.  We check that every member
  # of the group (all 4 are eligible) has a broadcast on their personal channel.
  @group.users.each do | u |
    channel = NotificationsChannel.channel_name( u.id )
    transmissions = broadcasts( channel )
    assert transmissions.size >= 1,
           "Expected an in-app notification for user #{u.id} on #{channel} but found none"

    payload = JSON.parse( transmissions.last )
    assert_equal 'warning', payload['priority'], "Expected priority 'warning' for reminder"
  end
end

When( /^an activity is marked available for the user$/ ) do
  # Call notify_availability directly to test the in-app broadcast path.
  @notified_activity = 'Test Activity'
  AdministrativeMailer.notify_availability( @user, @notified_activity )
end

Then( /^an in-app availability notification should have been broadcast to the user$/ ) do
  channel       = NotificationsChannel.channel_name( @user.id )
  transmissions = broadcasts( channel )

  assert transmissions.size >= 1,
         "Expected an in-app notification on #{channel} but found none"

  payload = JSON.parse( transmissions.last )
  assert_equal 'info', payload['priority'], "Expected priority 'info' for availability notification"
  assert_includes payload['message'], @notified_activity,
                  "Expected message to mention '#{@notified_activity}'"
end
