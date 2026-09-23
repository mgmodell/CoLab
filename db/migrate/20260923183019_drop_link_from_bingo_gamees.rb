class DropLinkFromBingoGamees < ActiveRecord::Migration[8.1]
  def change
    remove_column :bingo_games, :link, :integer
  end
end
