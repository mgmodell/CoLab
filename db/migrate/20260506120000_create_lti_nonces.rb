# frozen_string_literal: true

# Stores the short-lived state/nonce pair generated during the LTI 1.3 OIDC
# login flow.  Keeping this in the database (rather than in the browser
# session) avoids the SameSite cookie problem: both /lti/login and /lti/launch
# are cross-site requests, so the session cookie is not reliably sent by the
# browser.  The record is deleted immediately after the matching launch is
# validated, making it single-use.
class CreateLtiNonces < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_nonces, if_not_exists: true do |t|
      t.string :state, null: false
      t.string :nonce, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :lti_nonces, :state, unique: true, if_not_exists: true
    add_index :lti_nonces, :expires_at, if_not_exists: true
  end
end
