# frozen_string_literal: true
class AddSchoolToUser < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :school, index: true, foreign_key: true
  end
end
