# frozen_string_literal: true

class CreateLtiConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :lti_connections do |t|
      t.references :connectable, polymorphic: true, null: false, type: :integer
      t.string :line_item_url
      t.string :ags_access_token_url
      t.string :client_id
      t.string :deployment_id
      t.string :iss

      t.timestamps
    end

    add_index :lti_connections, %i[connectable_type connectable_id], unique: true,
              name: 'index_lti_connections_on_connectable'
  end
end
