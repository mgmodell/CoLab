# frozen_string_literal: true
class CandidateListsController < ApplicationController
  before_action :set_candidate_list, only: [:edit, :show, :update, :request_collaboration]

  def edit
    if @candidate_list.bingo_game.reviewed
      render :show
    elsif !@candidate_list.bingo_game.is_open?
      redirect_to :root_path, notice: "This list is no longer available for editing"
    end
  end

  def request_collaboration
    desired = params[:desired] == 'yes'
    if desired
      @candidate_list.group_requested = true
      @candidate_list.save
      @candidate_list = merge_to_group_list(@candidate_list) if @candidate_list.others_requested_help == 1
    else
      @candidate_list.bingo_game.project.group_for_user(@current_user).users.each do |user|
        cl = @candidate_list.bingo_game.candidate_list_for_user(user)
        cl.group_requested = false
        cl.save
      end
    end
    render :edit
  end

  # Merge all the lists, add the merged whole to a new, group candidate_list,
  # set is_group on all existing lists and then return the new list
  def merge_to_group_list(candidate_list)
    merged_list = []
    merger_group = candidate_list.bingo_game.project.group_for_user(candidate_list.user)
    required_terms = candidate_list.bingo_game.required_terms_for_group(merger_group)

    merger_group.users.each do |group_member|
      cl = candidate_list.bingo_game.candidate_list_for_user(group_member)
      cl.is_group = true
      cl.candidates.each do |candidate|
        merged_list << candidate if candidate.term.present? || candidate.definition.present?
      end
      cl.save
    end
    if merged_list.count < (required_terms - 1)
      merged_list.count.upto ( required_terms - 1) do
        merged_list << Candidate.new('term' => '', 'definition' => '')
      end
    end

    cl = CandidateList.new
    cl.group = merger_group
    cl.candidates = merged_list
    cl.is_group = true
    cl.bingo_game = candidate_list.bingo_game
    cl.save
    cl
  end

  def update
    if !@candidate_list.bingo_game.is_open?
      redirect_to :show
    else
      respond_to do |format|
        if @candidate_list.update(candidate_list_params)
          format.html { redirect_to edit_candidate_list_path(@candidate_list), notice: 'Your list was successfully saved.' }
        else
          format.html { render :edit }
        end
      end
    end
  end

  def show
    if !@candidate_list.bingo_game.reviewed
      redirect_to :root_path, notice: "This list is not yet ready for review"
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
