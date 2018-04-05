# frozen_string_literal: true

class BingoBoard < ApplicationRecord
  belongs_to :bingo_game, inverse_of: :bingo_boards
  belongs_to :user, inverse_of: :bingo_boards
  has_many :bingo_cells, inverse_of: :bingo_board, dependent: :destroy

  has_many :concepts, through: :bingo_cells

  accepts_nested_attributes_for :bingo_cells
end
