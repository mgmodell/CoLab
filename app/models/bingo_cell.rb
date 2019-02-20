# frozen_string_literal: true

class BingoCell < ApplicationRecord
  belongs_to :bingo_board, inverse_of: :bingo_cells
  belongs_to :concept
  belongs_to :candidate, inverse_of: :bingo_cells, optional: true

  def indeks_as_letter
    (indeks + 64).chr
  end
end
