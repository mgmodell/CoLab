# frozen_string_literal: true

class CandidateListsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[demo_play demo_entry]
  before_action :demo_user, only: %i[demo_play demo_entry]

  before_action :set_candidate_list, only: %i[edit show update request_collaboration list_stats]

  include Demoable

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
      notice = t('candidate_lists.no_longer_available')
      redirect_to :root_path, notice: notice
    end
  end

  def request_collaboration
    @title = t '.title'
    desired = params[:desired] == 'yes'
    if desired
      @candidate_list.group_requested = true
      @candidate_list.save
      logger.debug @candidate_list.errors.full_messages unless @candidate_list.errors.empty?
      @candidate_list = merge_to_group_list(@candidate_list) if @candidate_list.others_requested_help == 1
    else
      @candidate_list.bingo_game.project.group_for_user(@current_user).users.each do |user|
        cl = @candidate_list.bingo_game.candidate_list_for_user(user)
        cl.group_requested = false
        cl.save
        logger.debug cl.errors.full_messages unless cl.errors.empty?
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
      redirect_to show_candidate_list_path
    else
      respond_to do |format|
        if @candidate_list.update(candidate_list_params)
          format.html do
            redirect_to edit_candidate_list_path(@candidate_list),
                        notice: (t 'candidate_lists.update_success')
          end
        else
          logger.debug @candidate_list.errors.full_messages unless @candidate_list.errors.empty?
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

  def demo_play
    @title = t 'demo_title',
               orig: (t 'candidate_lists.show.title')
    @candidate_list = CandidateList.new(id: -1,
                                        is_group: false)
    @candidate_list.user = @current_user
    demo_project = Project.new(id: -1,
                               name: (t :demo_project),
                               course_id: -1)

    @candidate_list.bingo_game = BingoGame.new(id: -42,
                                               topic: (t 'candidate_lists.demo_bingo_topic'),
                                               description: (t 'candidate_lists.demo_bingo_description'),
                                               end_date: 2.day.from_now.end_of_day,
                                               individual_count: 10)

    render :show
  end

  def demo_entry
    @title = t 'demo_title',
               orig: (t 'candidate_lists.edit.title')
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
                                               description: (t 'candidate_lists.demo_description'),
                                               end_date: 4.day.from_now.end_of_day,
                                               group_option: true,
                                               project: demo_project,
                                               group_discount: 33,
                                               individual_count: 10)

    @candidate_list.candidates = []

    6.times do |index|
      @candidate_list.candidates << Candidate.new(id: 0, term: (t "candidate_lists.demo_term#{index + 1}"),
                                                  definition: (t "candidate_lists.demo_def#{index + 1}"),
                                                  candidate_list: @candidate_list)
    end

    # Add in the remainder elements
    4.times do
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
    flash[:notice] = t('candidate_lists.demo_success')
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
      cl.candidates.includes(:user).each do |candidate|
        merged_list << candidate if candidate.term.present? || candidate.definition.present?
      end
      cl.save
      logger.debug cl.errors.full_messages unless cl.errors.empty?
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
    logger.debug cl.errors.full_messages unless cl.errors.empty?
    cl
  end

  private

  def merge_individuals_to_group; end

  # Use callbacks to share common setup or constraints between actions.
  def set_candidate_list
    if params[:id] == '-1' # Support for demo
      flash[:notice] = t('candidate_lists.demo_colab_success')
      redirect_to root_url
    else
      @candidate_list = CandidateList.find(params[:id])
    end
  end

  def candidate_list_params
    params.require(:candidate_list).permit(:is_group, candidates_attributes: %i[id term definition user_id])
  end
end
