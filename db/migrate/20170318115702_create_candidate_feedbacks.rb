# frozen_string_literal: true
class CreateCandidateFeedbacks < ActiveRecord::Migration[4.2]
  def change
    create_table :candidate_feedbacks do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
