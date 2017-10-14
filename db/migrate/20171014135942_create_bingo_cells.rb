class CreateBingoCells < ActiveRecord::Migration
  def change
    create_table :bingo_cells do |t|
      t.references :bingo_board, index: true, foreign_key: true
      t.references :concept, index: true, foreign_key: true
      t.integer :row
      t.integer :column
      t.boolean :selected

      t.timestamps null: false
    end
  end
end
