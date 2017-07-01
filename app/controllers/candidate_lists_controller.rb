# frozen_string_literal: true
class CandidateListsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:demo_complete]
  before_action :set_candidate_list, only: [:edit, :show, :update, :request_collaboration, :list_stats]

  def list_stats
    @title = t '.title'
  end

  def edit
    @title = t '.title'
    @term_counts = {}
    @candidate_list.candidates.each do |candidate|
      @term_counts[candidate.filtered_consistent] = @term_counts[candidate.filtered_consistent].to_i + 1
    end

    empties = @candidate_list.expected_count - @candidate_list.candidates.count

    empties.times do
      @candidate_list.candidates.build(term: '', definition: '',
                                       user_id: @current_user.id)
    end

    if @candidate_list.bingo_game.reviewed
      render :show
    elsif !@candidate_list.bingo_game.is_open?
      redirect_to :root_path, notice: 'This list is no longer available for editing'
    end
  end

  def request_collaboration
    @title = t '.title'
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
    @term_counts = {}
    @candidate_list.candidates.each do |candidate|
      @term_counts[candidate.filtered_consistent] = @term_counts[candidate.filtered_consistent].to_i + 1
    end
    render :edit
  end

  def update
    if !@candidate_list.bingo_game.is_open?
      redirect_to :show
    else
      respond_to do |format|
        if @candidate_list.update(candidate_list_params)
          format.html do
            redirect_to edit_candidate_list_path(@candidate_list),
                        notice: (t 'candidate_lists.update_success')
          end
        else
          format.html { render :edit }
        end
      end
    end
  end

  def show
    @title = t '.title'
    unless @candidate_list.bingo_game.reviewed
      redirect_to :root_path, notice: (t 'candidate_lists.not_ready_for_review')
    end
  end

  def demo_complete
    @title = t 'candidate_lists.demo_title'
    if @current_user.nil?
      @current_user = User.new(
        first_name: (t :demo_surname_1),
        last_name: (t :demo_fam_name_1),
        timezone: (t :demo_user_tz)
      )
    end
    demo_group = Group.new
    demo_group.name = t :demo_group
    demo_group.users = [@current_user]
    @candidate_list = CandidateList.new(id: -1,
                                        is_group: false)
    @candidate_list.group = demo_group
    @candidate_list.user = @current_user
    demo_project = Project.new(id: -1,
                               name: (t :demo_project),
                               course_id: -1)
    demo_project.groups << demo_group

    @candidate_list.bingo_game = BingoGame.new(id: -1,
                                               topic: (t 'candidate_lists.demo_topic'),
                                               end_date: 2.day.from_now.end_of_day,
                                               group_option: true,
                                               project: demo_project,
                                               group_discount: 33,
                                               individual_count: 10)

    @candidate_list.candidates = []

    5.times do |index|
      @candidate_list.candidates << Candidate.new(id: 0, term: (t "candidate_lists.demo_term#{index + 1}"),
                                                  definition: (t "candidate_lists.demo_def#{index + 1}"),
                                                  candidate_list: @candidate_list)
    end

    # Add in the remainder elements
    5.times do
      @candidate_list.candidates.build(term: '', definition: '',
                                       user_id: @current_user.id)
    end

    @term_counts = {}
    @candidate_list.candidates.each do |candidate|
      candidate.clean_data
      @term_counts[candidate.filtered_consistent] = @term_counts[candidate.filtered_consistent].to_i + 1
    end

    render :edit
  end

  # present as a hack to support the demo
  def create
    flash[:notice] = 'Your response would have been successfully saved. The demonstration is finished.'
    redirect_to root_url
  end

  protected

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
        merged_list << Candidate.new('term' => '', 'definition' => '', user: @current_user)
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

  private

  def merge_individuals_to_group; end

  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_list
    if params[:id] == '-1' # Support for demo
      flash[:notice] = 'Collaboration would have been successfully requested. The demonstration is finished.'
      redirect_to root_url
    else
      @candidate_list = CandidateList.find(params[:id])
    end
  end

  def candidate_list_params
    params.require(:candidate_list).permit(:is_group, candidates_attributes: [:id, :term, :definition, :user_id])
  end
end
