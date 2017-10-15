# frozen_string_literal: true
class BingoBoard < ActiveRecord::Base
  belongs_to :BingoGame
  belongs_to :User

  accepts_nested_attributes_for :bingo_cells
end
