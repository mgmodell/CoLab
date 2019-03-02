class AddIterationToBingoBoard < ActiveRecord::Migration[5.1]
  def change
    add_column :bingo_boards, :iteration, :integer, default: 0
  end
end
