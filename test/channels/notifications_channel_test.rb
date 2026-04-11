# frozen_string_literal: true

require 'test_helper'
require 'action_cable/testing'

class NotificationsChannelTest < ActionCable::Channel::TestCase
  # ------------------------------------------------------------------
  # subscribed
  # ------------------------------------------------------------------

  test 'subscribes and starts streaming for the current user' do
    # stub_connection provides a mock current_user
    stub_connection current_user: users( :one )

    subscribe

    assert subscription.confirmed?
    assert_has_stream "notifications_user_#{users( :one ).id}"
  end

  # ------------------------------------------------------------------
  # unsubscribed
  # ------------------------------------------------------------------

  test 'stops all streams on unsubscribe' do
    stub_connection current_user: users( :one )

    subscribe
    unsubscribe

    assert_no_streams
  end

  # ------------------------------------------------------------------
  # channel_name helper
  # ------------------------------------------------------------------

  test 'channel_name returns the expected string' do
    assert_equal 'notifications_user_42',
                 NotificationsChannel.channel_name( 42 )
  end

  # ------------------------------------------------------------------
  # broadcast_to_user
  # ------------------------------------------------------------------

  test 'broadcast_to_user sends one broadcast to the correct channel' do
    assert_broadcasts( 'notifications_user_7', 1 ) do
      NotificationsChannel.broadcast_to_user(
        user_id: 7,
        message: 'Hello',
        priority: 'info'
      )
    end
  end

  test 'broadcast_to_user payload contains message and priority' do
    NotificationsChannel.broadcast_to_user(
      user_id: 8,
      message: 'You have pending activities to complete.',
      priority: 'warning'
    )

    transmissions = broadcasts( 'notifications_user_8' )
    assert_equal 1, transmissions.size

    payload = JSON.parse( transmissions.first )
    assert_equal 'You have pending activities to complete.', payload['message']
    assert_equal 'warning', payload['priority']
  end

  test 'broadcast_to_user defaults priority to info' do
    NotificationsChannel.broadcast_to_user(
      user_id: 9,
      message: 'An activity is available'
    )

    transmissions = broadcasts( 'notifications_user_9' )
    payload = JSON.parse( transmissions.first )
    assert_equal 'info', payload['priority']
  end

  test 'broadcast_to_user sends to distinct channels per user' do
    NotificationsChannel.broadcast_to_user( user_id: 1, message: 'msg A', priority: 'info' )
    NotificationsChannel.broadcast_to_user( user_id: 2, message: 'msg B', priority: 'info' )

    assert_equal 1, broadcasts( 'notifications_user_1' ).size
    assert_equal 1, broadcasts( 'notifications_user_2' ).size
    assert_equal 0, broadcasts( 'notifications_user_3' ).size
  end
end
