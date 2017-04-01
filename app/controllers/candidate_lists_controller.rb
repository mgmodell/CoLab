# frozen_string_literal: true
class CandidateListsController < ApplicationController
  before_action :set_candidate_list, only: [ :enter_terms, :request_collaboration ]

  def enter_terms

  end

  def request_collaboration
    desired = params[ :desired ]
    if desired
      #if you are the first...
      group.users.each do |user|
        #send an email saying the group requested collaboration
      end
    else
      #reset the rest of the groups to not requested
    end
    group_requested = true
  end

  def save_terms
    respond_to do |format|
      if @candidate_list.update(course_params)
        format.html { redirect_to enter_terms_path(@candidate_list), notice: 'Your list was successfully saved.' }
      else
        format.html { render :enter_terms }
      end
    end
  end

  private
  def merge_individuals_to_group

  end

  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_list
    @candidate_list = CandidateList.find(params[:candidate_list_id])
  end

  def candidate_list_params
    params.require(:candidate_list).permit(:is_group, candidates: [:name, :definition])
  end
end
