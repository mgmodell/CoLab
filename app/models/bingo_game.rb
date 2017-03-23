class BingoGame < ActiveRecord::Base
  belongs_to :group, inverse_of: :bingo_games
  has_many :candidate_lists, inverse_of: :bingo_game, dependent: :destroy
end
