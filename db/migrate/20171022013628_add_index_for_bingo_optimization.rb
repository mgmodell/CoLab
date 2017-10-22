class AddIndexForBingoOptimization < ActiveRecord::Migration
  def change
    add_index :concepts, :name, name: 'concept_fulltext', type: :fulltext
    add_index :candidates, :term, length: 2
    add_index :candidates, :definition, length: 2
    add_index :users, :bingo_boards_id
    add_index :users, :primary_language_id
  end
end
