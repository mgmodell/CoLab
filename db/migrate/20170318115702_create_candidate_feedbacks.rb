class CreateCandidateFeedbacks < ActiveRecord::Migration
  def change
    create_table :candidate_feedbacks do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
