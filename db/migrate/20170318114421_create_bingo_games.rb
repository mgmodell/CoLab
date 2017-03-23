class CreateBingoGames < ActiveRecord::Migration
  def change
    create_table :bingo_games do |t|
      t.string :topic
      t.text :description
      t.string :link
      t.string :source
      t.boolean :group_option
      t.integer :individual_count
      t.integer :group_count
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
