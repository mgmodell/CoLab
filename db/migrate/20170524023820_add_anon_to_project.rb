# frozen_string_literal: true
class AddAnonToProject < ActiveRecord::Migration
  def change
    add_column :projects, :anon_name, :string
  end
end
