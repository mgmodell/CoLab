# frozen_string_literal: true
class AddGroupDiscountToBingoGame < ActiveRecord::Migration[4.2]
  def change
    add_column :bingo_games, :group_discount, :integer
  end
end
