# frozen_string_literal: true
class AddAnonToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :anon_name, :string
  end
end
