# frozen_string_literal: true

class BingoCell < ApplicationRecord
  belongs_to :bingo_board, inverse_of: :bingo_cells
  belongs_to :concept

end
