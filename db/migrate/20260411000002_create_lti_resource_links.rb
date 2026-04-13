# frozen_string_literal: true

class CreateLtiResourceLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_resource_links, if_not_exists: true do |t|
      t.bigint :lti_deployment_id, null: false
      t.string :resource_link_id, null: false
      t.string :context_id
      t.string :context_title
      # Use type: :integer to match courses.id which is int(11), not the default bigint
      t.references :course, type: :integer, foreign_key: true
      t.references :assignment, foreign_key: true
      t.string :line_item_url
      t.string :names_roles_url

      t.timestamps
    end

    add_index :lti_resource_links, :lti_deployment_id, if_not_exists: true
    add_index :lti_resource_links,
              %i[lti_deployment_id resource_link_id],
              unique: true,
              name: 'index_lti_resource_links_on_deployment_and_link',
              if_not_exists: true
    add_foreign_key :lti_resource_links, :lti_deployments, if_not_exists: true
  end
end
