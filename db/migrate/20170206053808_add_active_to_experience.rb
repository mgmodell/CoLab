# frozen_string_literal: true
class AddActiveToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :active, :boolean
  end
end
