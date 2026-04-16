# frozen_string_literal: true

class CreateLtiDeployments < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_deployments, if_not_exists: true do |t|
      t.string :issuer, null: false
      t.string :client_id, null: false
      t.string :auth_login_url, null: false
      t.string :auth_token_url, null: false
      t.string :key_set_url, null: false
      t.string :deployment_id
      t.string :tool_url

      t.timestamps
    end

    add_index :lti_deployments, %i[issuer client_id], unique: true, if_not_exists: true
    add_index :lti_deployments, :deployment_id, if_not_exists: true
  end
end
