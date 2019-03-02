class AddBoardTypeToBingoBoard < ActiveRecord::Migration[5.2]
  def change
    add_column :bingo_boards, :board_type, :integer, default: 0
  end
end
