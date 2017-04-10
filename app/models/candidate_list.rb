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
      required_term_count = bingo_game.required_terms_for_group( self.group )
      percent = 100 * candidates.completed.count / required_term_count
    else
      percent = 100 * candidates.completed.count / bingo_game.individual_count
    end
    percent
  end

  def others_requested_help
    requested_count = 0
    tentative_group = bingo_game.project.group_for_user( self.user )
    if bingo_game.group_option? && tentative_group.present?
      tentative_group.users.each do |user|
        requested_count += 1 if bingo_game.candidate_list_for_user(user).group_requested
      end
    end
    tentative_group.nil? ? 0 : requested_count.to_f / tentative_group.users.count

  end
end
