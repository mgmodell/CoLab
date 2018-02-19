# frozen_string_literal: true
class AddNumberToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :number, :string
  end
end
