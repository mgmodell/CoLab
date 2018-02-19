# frozen_string_literal: true
class AddAnonToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :anon_name, :string
    add_column :courses, :anon_number, :string
  end
end
