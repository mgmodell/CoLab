# frozen_string_literal: true

class AddActivityToLtiResourceLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :lti_resource_links, :activity_type, :string
    add_column :lti_resource_links, :activity_id, :integer
  end
end
