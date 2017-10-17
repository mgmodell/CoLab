class AddWinClaimedToBingoBoard < ActiveRecord::Migration
  def change
    add_column :bingo_boards, :win_claimed, :boolean
  end
end
