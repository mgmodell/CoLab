# frozen_string_literal: true
class CandidateList < ActiveRecord::Base
  belongs_to :user, inverse_of: :candidate_lists
  belongs_to :group, inverse_of: :candidate_lists
  belongs_to :bingo_game, inverse_of: :candidate_lists
  has_many :candidates, inverse_of: :candidate_list, dependent: :destroy

  def percent_complete
    percent = 0
    if is_group
      percent = 100 * candidates.completed.count / bingo_game.group_count
    else
      percent = 100 * candidates.completed.count / bingo_game.individual_count
    end
    percent
  end
end
