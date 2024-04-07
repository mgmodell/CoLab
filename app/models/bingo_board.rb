# frozen_string_literal: true

class BingoBoard < ApplicationRecord
  belongs_to :bingo_game, inverse_of: :bingo_boards
  belongs_to :user, inverse_of: :bingo_boards
  has_many :bingo_cells, inverse_of: :bingo_board, dependent: :destroy
  has_one_attached :result_img

  has_many :concepts, through: :bingo_cells
  enum board_type: { playable: 0, worksheet: 1 }

  accepts_nested_attributes_for :bingo_cells

  delegate :first_name, :last_name, to: :user, prefix: true
  delegate :end_date, :course, :topic, :size, to: :bingo_game, prefix: true
end
