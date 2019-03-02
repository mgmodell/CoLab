class AddWinClaimedToBingoBoard < ActiveRecord::Migration[4.2]
  def change
    add_column :bingo_boards, :win_claimed, :boolean
  end
end
