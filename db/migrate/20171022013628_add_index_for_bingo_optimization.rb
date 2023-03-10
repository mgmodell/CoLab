class AddIndexForBingoOptimization < ActiveRecord::Migration[4.2]
  def change
    add_index :concepts, :name, name: 'concept_fulltext', type: :fulltext
    add_index :candidates, :term, length: 2
    add_index :candidates, :definition, length: 2
  end
end
