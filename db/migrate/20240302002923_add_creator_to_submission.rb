class AddCreatorToSubmission < ActiveRecord::Migration[7.1]
  def change
    add_reference :submissions, :creator,
        foreign_key: {to_table: :users}, null: false,
        type: :integer
  end
end
