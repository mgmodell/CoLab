# frozen_string_literal: true
class CreateGroupProjectCount < ActiveRecord::Migration[4.2]
  def change
    create_table :group_project_counts do |t|
      t.string :name
      t.string :description
    end
  end
end
