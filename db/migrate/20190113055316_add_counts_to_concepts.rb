class AddCountsToConcepts < ActiveRecord::Migration[5.2]
  def change
    add_column :concepts, :candidates_count,
               :integer, default: 0, null: false
    add_column :concepts, :courses_count,
               :integer, default: 0, null: false
    add_column :concepts, :bingo_games_count,
               :integer, default: 0, null: false
  end
end
