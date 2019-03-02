# frozen_string_literal: true
class AddActiveToExperience < ActiveRecord::Migration[4.2]
  def change
    add_column :experiences, :active, :boolean
  end
end
