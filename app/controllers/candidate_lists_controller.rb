# frozen_string_literal: true
class CandidateListsController < ApplicationController
  before_action :set_candidate_list

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_list
    @candidate_list = CandidateList.find(params[:id])
    @course = @@candidate_list.bingo_game.course
  end

  def candidate_list_params
    params.require(:candidate_list).permit(:is_group, candidates: [:name, :definition ] )
  end
end
