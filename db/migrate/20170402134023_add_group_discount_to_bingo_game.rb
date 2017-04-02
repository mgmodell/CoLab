# frozen_string_literal: true
class AddGroupDiscountToBingoGame < ActiveRecord::Migration
  def change
    add_column :bingo_games, :group_discount, :integer
  end
end
