# frozen_string_literal: true

class BingoCell < ActiveRecord::Base
  belongs_to :bingo_board, inverse_of: :bingo_cells
  belongs_to :concept
end
