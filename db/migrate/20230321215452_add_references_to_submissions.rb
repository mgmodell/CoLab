class AddReferencesToSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_reference :submissions, :user, null: false, foreign_key: true, type: :integer
    add_reference :submissions, :group, null: true, foreign_key: true, type: :integer
    add_reference :submissions, :assignment, null: false, foreign_key: true, type: :bigint
    add_reference :submissions, :rubric, null: false, foreign_key: true, type: :bigint
  end
end
