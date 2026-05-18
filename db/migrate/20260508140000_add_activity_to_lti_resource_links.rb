# frozen_string_literal: true

class AddActivityToLtiResourceLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :lti_resource_links, :activity_type, :string, if_not_exists: true
    add_column :lti_resource_links, :activity_id, :integer, if_not_exists: true

  end
end
