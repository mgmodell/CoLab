# frozen_string_literal: true
class CandidateList < ActiveRecord::Base
  belongs_to :user, inverse_of: :candidate_lists
  belongs_to :group, inverse_of: :candidate_lists
  belongs_to :bingo_game, inverse_of: :candidate_lists
  has_many :candidates, inverse_of: :candidate_list, dependent: :destroy

  accepts_nested_attributes_for :candidates

  def percent_complete
    percent = 0
    if is_group
      percent = 100 * candidates.completed.count / bingo_game.group_count
    else
      percent = 100 * candidates.completed.count / bingo_game.individual_count
    end
    percent
  end

  def others_requested_help?
    if bingo_game.group_option? && group.present?
      group.users.each do |user|
        return true if bingo_game.candidate_list_for_user( user ).group_requested
      end
    end

    return false
  end
end
