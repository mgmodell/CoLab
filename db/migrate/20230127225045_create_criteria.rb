class CreateCriteria < ActiveRecord::Migration[7.0]
  def change
    create_table :criteria do |t|
      t.references :rubric, null: false, foreign_key: true
      t.string :description
      t.integer :weight, null: false, default: 1
      t.integer :sequence, null: false
      t.text :l1_description, null: true
      t.text :l2_description, null: true
      t.text :l3_description, null: true
      t.text :l4_description, null: true
      t.text :l5_description, null: true

      t.timestamps
    end
  end
end
