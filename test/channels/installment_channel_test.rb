# frozen_string_literal: true

require 'test_helper'
require 'action_cable/testing'

class InstallmentChannelTest < ActionCable::Channel::TestCase
  # ------------------------------------------------------------------
  # subscribed
  # ------------------------------------------------------------------

  test 'subscribes and starts streaming when assessment_id and group_id are provided' do
    subscribe assessment_id: 42, group_id: 7

    assert subscription.confirmed?
    assert_has_stream 'installment_42_group_7'
  end

  test 'rejects subscription when assessment_id is missing' do
    subscribe group_id: 7

    assert subscription.rejected?
  end

  test 'rejects subscription when group_id is missing' do
    subscribe assessment_id: 42

    assert subscription.rejected?
  end

  test 'rejects subscription when both params are missing' do
    subscribe({})

    assert subscription.rejected?
  end

  # ------------------------------------------------------------------
  # unsubscribed
  # ------------------------------------------------------------------

  test 'stops all streams on unsubscribe' do
    subscribe assessment_id: 1, group_id: 1
    unsubscribe

    assert_no_streams
  end

  # ------------------------------------------------------------------
  # channel_name helper
  # ------------------------------------------------------------------

  test 'channel_name returns the expected string' do
    assert_equal 'installment_10_group_20',
                 InstallmentChannel.channel_name( 10, 20 )
  end

  # ------------------------------------------------------------------
  # broadcast_submission
  # ------------------------------------------------------------------

  test 'broadcast_submission sends correct payload to the group channel' do
    # Build minimal objects with Struct so the test has no DB dependency.
    fake_user = Struct.new( :id, :name_str ) do
      def name( with_email = true )
        name_str
      end
    end.new( 99, 'Jane Doe' )

    fake_installment = Struct.new( :assessment_id, :group_id, :user_id, :user ).new(
      3, 7, 99, fake_user
    )

    assert_broadcasts( 'installment_3_group_7', 1 ) do
      InstallmentChannel.broadcast_submission( fake_installment )
    end
  end

  test 'broadcast_submission payload contains expected keys and values' do
    fake_user = Struct.new( :id, :name_str ) do
      def name( with_email = true )
        name_str
      end
    end.new( 55, 'John Smith' )

    fake_installment = Struct.new( :assessment_id, :group_id, :user_id, :user ).new(
      5, 9, 55, fake_user
    )

    InstallmentChannel.broadcast_submission( fake_installment )

    transmissions = broadcasts( 'installment_5_group_9' )
    assert_equal 1, transmissions.size

    payload = JSON.parse( transmissions.first )
    assert_equal 'installment_saved', payload['event']
    assert_equal 55,                  payload['user_id']
    assert_equal 'John Smith',        payload['user_name']
    assert_equal 5,                   payload['assessment_id']
    assert_equal 9,                   payload['group_id']
  end
end
