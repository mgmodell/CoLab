# frozen_string_literal: true

class CreateLtiResourceLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_resource_links do |t|
      t.references :lti_deployment, null: false, foreign_key: true
      t.string :resource_link_id, null: false
      t.string :context_id
      t.string :context_title
      t.references :course, foreign_key: true
      t.references :assignment, foreign_key: true
      t.string :line_item_url
      t.string :names_roles_url

      t.timestamps
    end

    add_index :lti_resource_links,
              %i[lti_deployment_id resource_link_id],
              unique: true,
              name: 'index_lti_resource_links_on_deployment_and_link'
  end
end
