# frozen_string_literal: true
class CandidateListsController < ApplicationController
  before_action :set_candidate_list, only: [:edit, :update, :request_collaboration]

  def edit; end

  def request_collaboration
    desired = params[:desired]
    if desired
      @candidate_list.group_requested = true
      @candidate_list.save
      @candidate_list = merge_to_group_list if @candidate_list.others_requested_help == 1
    else
      @candidate_list.bingo.project.get_group_for_user( @current_user ).users.each do |user|
        cl = @candidate_list.bingo.candidate_list_for_user( user )
        cl.group_requested = false
        cl.save
      end
    end
    render :edit
  end

  #TODO: Merge all the lists, add the merged whole to a new, group candidate_list,
  # set is_group on all existing lists and then return the new list
  def merge_to_group_list

  end

  def update
    respond_to do |format|
      if @candidate_list.update(candidate_list_params)
        format.html { redirect_to edit_candidate_list_path(@candidate_list), notice: 'Your list was successfully saved.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def merge_individuals_to_group; end

  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_list
    @candidate_list = CandidateList.find(params[:id])
  end

  def candidate_list_params
    params.require(:candidate_list).permit(:is_group, candidates_attributes: [:id, :term, :definition])
  end
end
