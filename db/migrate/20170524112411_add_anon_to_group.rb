# frozen_string_literal: true
class AddAnonToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :anon_name, :string
  end
end
