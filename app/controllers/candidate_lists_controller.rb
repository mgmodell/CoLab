# frozen_string_literal: true

class CandidateListsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[demo_play demo_entry]
  before_action :demo_user, only: %i[demo_play demo_entry]

  before_action :set_candidate_list, only: %i[edit show update request_collaboration]

  include Demoable

  def edit
    consent_log = @candidate_list.course.get_consent_log user: current_user

    if consent_log.present? && !consent_log.presented?
      redirect_to edit_consent_log_path( consent_form_id: consent_log.consent_form_id )
    else
      # Aggregation Optimization: Replaced in-memory Ruby counting loop with direct SQL group count
      @term_counts = @candidate_list.candidates.group(:filtered_consistent).count

      empties = @candidate_list.expected_count - @candidate_list.candidates.count

      empties.times do
        @candidate_list.candidates.build( term: '', definition: '', user_id: current_user.id )
      end

      if @candidate_list.bingo_game_reviewed
        render :show
      elsif !@candidate_list.bingo_game.is_open?
        notice = t( 'candidate_lists.no_longer_available' )
        redirect_to :root_path, notice:
      end
    end
  end

  def get_candidate_list
    bingo_game = BingoGame.find( params[:bingo_game_id] )
    candidate_list = bingo_game.candidate_list_for_user( current_user )

    group = ( bingo_game.project.group_for_user( current_user ) if bingo_game.group_option? )

    respond_to do | format |
      format.json do
        render json: {
          id: candidate_list.id,
          topic: bingo_game.topic,
          description: bingo_game.description,
          group_option: bingo_game.group_option?,
          end_date: bingo_game.end_date,
          group_name: group.presence&.get_name( false ),
          is_group: candidate_list.is_group?,
          expected_count: candidate_list.expected_count,
          candidates: candidate_list.candidates.as_json(
            only: %i[id term definition filtered_consistent candidate_feedback_id]
          ),
          others_requested_help: candidate_list.others_requested_help,
          help_requested: candidate_list.group_requested,
          request_collaboration_url: request_collaboration_path(
            bingo_game_id: bingo_game.id, desired: ''
          )
        }
      end
    end
  end

  def request_collaboration
    desired = params[:desired].casecmp( 'true' ).zero?
    if desired
      @candidate_list.group_requested = true
      @candidate_list.save
      logger.debug @candidate_list.errors.full_messages unless @candidate_list.errors.empty?
      @candidate_list = merge_to_group_list( @candidate_list ) if 1 == @candidate_list.others_requested_help
    else
      @candidate_list.transaction do
        # N+1 Fix: Includes candidate_lists when iterating through group users
        group_users = @candidate_list.bingo_game.project.group_for_user( current_user ).users.includes(:candidate_lists)
        group_users.each do | user |
          cl = @candidate_list.bingo_game.candidate_list_for_user( user )
          cl.group_requested = false
          cl.save!
          logger.debug cl.errors.full_messages unless cl.errors.empty?
        end
      end
    end
    
    # Aggregation Optimization: Replaced in-memory loop with direct SQL aggregate grouping
    @term_counts = @candidate_list.candidates.group(:filtered_consistent).count

    respond_to do | format |
      format.json do
        render json: {
          id: @candidate_list.id,
          is_group: @candidate_list.is_group?,
          expected_count: @candidate_list.expected_count,
          candidates: @candidate_list.candidates.as_json(
            only: %i[id term definition filtered_consistent candidate_feedback_id]
          ),
          others_requested_help: @candidate_list.others_requested_help,
          help_requested: @candidate_list.group_requested,
          messages: { main: 'All good' }
        }
      end
    end
  end

  def update
    if !@candidate_list.bingo_game.is_open?
      if @candidate_list.bingo_game.reviewed
        redirect_to :root_path, notice: ( t 'candidate_lists.list_closed' )
      else
        redirect_to show_candidate_list_path
      end
    else
      respond_to do | format |
        params[:candidates].each do | candidate_data |
          term = candidate_data[:term]
          definition = candidate_data[:definition]
          id = candidate_data[:id]

          if id.blank?
            @candidate_list.candidates.build(
              term:,
              definition:,
              user: current_user
            )
          else
            candidate = @candidate_list.candidates.find { | c | c.id == id }
            candidate.term = term
            candidate.definition = definition
          end
        end

        if @candidate_list.save
          @candidate_list.reload
          message = t 'candidate_lists.update_success'
          format.json do
            render json: {
              id: @candidate_list.id,
              is_group: @candidate_list.is_group?,
              expected_count: @candidate_list.expected_count,
              candidates: @candidate_list.candidates.as_json(
                only: %i[id term definition filtered_consistent candidate_feedback_id]
              ),
              others_requested_help: @candidate_list.others_requested_help,
              help_requested: @candidate_list.group_requested,
              messages: { main: message }
            }
          end
        else
          logger.debug @candidate_list.errors.full_messages unless @candidate_list.errors.empty?
          format.json do
            messages = @candidate_list.errors.to_h
            messages[:main] = 'Please review the errors noted'
            render json: {
              id: @candidate_list.id,
              is_group: @candidate_list.is_group?,
              expected_count: @candidate_list.expected_count,
              candidates: @candidate_list.candidates.as_json(
                only: %i[id term definition filtered_consistent candidate_feedback_id]
              ),
              others_requested_help: @candidate_list.others_requested_help,
              help_requested: @candidate_list.group_requested,
              messages:
            }
          end
        end
      end
    end
  end

  def show
    return if @candidate_list.bingo_game.reviewed

    redirect_to :root_path, notice: ( t 'candidate_lists.not_ready_for_review' )
  end

  def demo_play
    @candidate_list = CandidateList.new( id: -1,
                                         contributor_count: 1,
                                         is_group: false )
    @candidate_list.user = current_user
    Project.new( id: -1,
                 name: ( t :demo_project ),
                 course_id: -1 )

    @candidate_list.bingo_game = BingoGame.new( id: -42,
                                                topic: ( t 'candidate_lists.demo_bingo_topic' ),
                                                description: ( t 'candidate_lists.demo_bingo_description' ),
                                                end_date: 2.days.from_now.end_of_day,
                                                individual_count: 10 )

    render :show
  end

  def demo_entry
    candidates = []

    6.times do | index |
      candidates << {
        id: 0,
        term: ( t "candidate_lists.demo_term#{index + 1}" ),
        definition: ( t "candidate_lists.demo_def#{index + 1}" ),
        filtered_consistent: Candidate.clean_term( t( "candidate_lists.demo_term#{index + 1}" ) ),
        candidate_feedback_id: 0
      }
    end

    respond_to do | format |
      format.json do
        render json: {
          id: -1,
          topic: ( t 'candidate_lists.demo_topic' ),
          description: ( t 'candidate_lists.demo_bingo_description' ),
          group_option: true,
          end_date: 4.days.from_now.end_of_day,
          group_name: ( t :demo_group ),
          is_group: false,
          expected_count: 10,
          candidates: candidates.as_json(
            only: %i[id term definition filtered_consistent candidate_feedback_id]
          ),
          others_requested_help: false,
          help_requested: false,
          request_collaboration_url: request_collaboration_path(
            bingo_game_id: -1, desired: ''
          )
        }
      end
    end
  end

  def create
    flash[:notice] = t( 'candidate_lists.demo_success' )
    redirect_to root_url
  end

  protected

  def merge_to_group_list( candidate_list )
    merger_group = candidate_list.bingo_game.project.group_for_user( candidate_list.user )
    required_terms = candidate_list.bingo_game.required_terms_for_contributors( merger_group.users.size )
    cl = nil

    merger_group.transaction do
      merged_list = []
      group_lists = []
      
      # N+1 Fix: Preload candidates for each user's candidate list
      merger_group.users.includes(candidate_lists: :candidates).each do | group_member |
        member_cl = candidate_list.bingo_game.candidate_list_for_user( group_member )
        member_cl.archived = true
        member_cl.candidates.includes( :user ).find_each do | candidate |
          merged_list << candidate if candidate.term.present? || candidate.definition.present?
        end
        member_cl.save!
        logger.debug member_cl.errors.full_messages unless member_cl.errors.empty?
        group_lists << member_cl
      end
      if merged_list.count < ( required_terms - 1 )
        merged_list.count.upto( required_terms - 1 ) do
          merged_list << Candidate.new( 'term' => '', 'definition' => '', user: current_user )
        end
      end

      cl = CandidateList.new
      cl.group = merger_group
      cl.contributor_count = merger_group.users.size
      cl.candidates = merged_list
      cl.is_group = true
      cl.bingo_game = candidate_list.bingo_game
      cl.save!
      logger.debug cl.errors.full_messages unless cl.errors.empty?

      group_lists.each do | member_cl |
        member_cl.current_candidate_list = cl
        member_cl.save!
        logger.debug member_cl.errors.full_messages unless member_cl.errors.empty?
      end
    end
    cl
  end

  private

  def set_candidate_list
    if '-1' == params[:bingo_game_id]
      flash[:notice] = t( 'candidate_lists.demo_colab_success' )
      redirect_to root_url
    else
      # N+1 Fix: Includes candidate list hierarchy and candidates
      bingo_game = BingoGame.includes(candidate_lists: %i[candidates current_candidate_list]).find_by id: params[:bingo_game_id]
      @candidate_list = bingo_game.candidate_list_for_user current_user
      @candidate_list = @candidate_list.current_candidate_list if @candidate_list.archived
    end
  end

  def candidate_list_params
    params.require( :candidate_list ).permit( candidates_attributes: %i[id term definition user_id] )
  end
end