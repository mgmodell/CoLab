# frozen_string_literal: true

require 'test_helper'
require 'action_cable/testing'

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  setup do
    @user = users( :one )
    # Ensure the user has a DeviseTokenAuth token
    @token  = @user.create_new_auth_token
    @uid    = @token['uid']
    @access = @token['access-token']
    @client = @token['client']
  end

  test 'connects when valid DeviseTokenAuth credentials are supplied' do
    connect '/cable',
            params: { uid: @uid, 'access-token': @access, client: @client }

    assert_equal @user.id, connection.current_user.id
  end

  test 'rejects connection when uid is missing' do
    assert_reject_connection do
      connect '/cable',
              params: { 'access-token': @access, client: @client }
    end
  end

  test 'rejects connection when access-token is missing' do
    assert_reject_connection do
      connect '/cable',
              params: { uid: @uid, client: @client }
    end
  end

  test 'rejects connection when client is missing' do
    assert_reject_connection do
      connect '/cable',
              params: { uid: @uid, 'access-token': @access }
    end
  end

  test 'rejects connection when access-token is invalid' do
    assert_reject_connection do
      connect '/cable',
              params: { uid: @uid, 'access-token': 'bad_token', client: @client }
    end
  end

  test 'rejects connection when no credentials are supplied' do
    assert_reject_connection do
      connect '/cable'
    end
  end
end
