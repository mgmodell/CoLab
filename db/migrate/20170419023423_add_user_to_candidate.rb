# frozen_string_literal: true
class AddUserToCandidate < ActiveRecord::Migration[4.2]
  def change
    add_reference :candidates, :user, index: true, foreign_key: true, null: false
  end
end
