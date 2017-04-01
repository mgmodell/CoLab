# frozen_string_literal: true
class CandidateListsController < ApplicationController
  before_action :set_candidate_list

  def enter_terms
    candidate_list_id = params[ :candidate_list_id ]

  end

  def request_collaboration
    candidate_list_id = params[ :candidate_list_id ]
    @candidate_list = CandidateList.find candidate_list_id

  end

  def save_terms

  end

  private
  def merge_individuals_to_group

  end

  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_list
    @candidate_list = CandidateList.find(params[:id])
    @course = @@candidate_list.bingo_game.course
  end

  def candidate_list_params
    params.require(:candidate_list).permit(:is_group, candidates: [:name, :definition])
  end
end
