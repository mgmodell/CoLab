# frozen_string_literal: true
class AddNumberToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :number, :string
  end
end
