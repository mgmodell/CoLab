# frozen_string_literal: true
class AddAnonToExperience < ActiveRecord::Migration[4.2]
  def change
    add_column :experiences, :anon_name, :string
  end
end
