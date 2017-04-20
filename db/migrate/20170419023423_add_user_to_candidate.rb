# frozen_string_literal: true
class AddUserToCandidate < ActiveRecord::Migration
  def change
    add_reference :candidates, :user, index: true, foreign_key: true, null: false
  end
end
