# frozen_string_literal: true
class AddExperienceToReaction < ActiveRecord::Migration[4.2]
  def change
    add_reference :reactions, :experience, index: true, foreign_key: true
  end
end
