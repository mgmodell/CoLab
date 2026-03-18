class AddUserToRubric < ActiveRecord::Migration[7.0]
  def change
    add_reference :rubrics, :user, null: true, foreign_key: true, type: :integer
    add_reference :rubrics, :school, null: true, foreign_key: true, type: :integer
  end
end
