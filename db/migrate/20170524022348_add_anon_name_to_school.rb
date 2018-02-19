# frozen_string_literal: true
class AddAnonNameToSchool < ActiveRecord::Migration[4.2]
  def change
    add_column :schools, :anon_name, :string
  end
end
