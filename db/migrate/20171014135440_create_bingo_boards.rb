class CreateBingoBoards < ActiveRecord::Migration
  def change
    create_table :bingo_boards do |t|
      t.references :bingo_game, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :winner

      t.timestamps null: false
    end
  end
end
