# frozen_string_literal: true
class AddAnonNameToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :anon_name, :string
  end
end
