class AddScoreToBingoBoard < ActiveRecord::Migration[6.0]
  def change
    add_column :bingo_boards, :performance, :integer
  end
end
