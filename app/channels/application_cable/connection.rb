# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # Authenticate the WebSocket connection using the same DeviseTokenAuth
    # headers that the REST API uses.  Clients pass uid, access-token, and
    # client as query-string parameters on the /cable URL.
    def find_verified_user
      uid          = request.params[:uid]
      access_token = request.params[:'access-token']
      client       = request.params[:client]

      if uid.present? && access_token.present? && client.present?
        user = User.find_by_uid( uid )
        if user&.valid_token?( access_token, client )
          user
        else
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end
