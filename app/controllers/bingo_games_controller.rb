# frozen_string_literal: true
class BingoGamesController < ApplicationController
  before_action :set_bingo_game, only: [:show, :edit, :update, :destroy, :review_candidates, :update_review_candidates]
  before_action :check_admin, except: [:next, :diagnose, :react, :update_review_candidates]

  def show
    @title = t '.title'
  end

  def edit
    @title = t '.title'
  end

  def index
    @title = t '.title'
    @bingo_games = []
    if @current_user.is_admin?
      @bingo_games = BingoGame.all
    else
      rosters = @current_user.rosters.instructorships
      rosters.each do |roster|
        @bingo_games.concat roster.course.bingo_games.to_a
      end
    end
  end

  def new
    @title = t '.title'
    @bingo_game = BingoGame.new
    @bingo_game.course_id = params[:course_id]
    @bingo_game.course = Course.find(params[:course_id])
    @bingo_game.start_date = @bingo_game.course.start_date
    @bingo_game.end_date = @bingo_game.course.end_date
  end

  def create
    @title = t '.title'
    @bingo_game = BingoGame.new(bingo_game_params)
    if @bingo_game.save
      redirect_to @bingo_game, notice: 'Bingo Game was successfully created.'
    else
      render :new
    end
  end

  def update
    @title = t '.title'
    if @bingo_game.update(bingo_game_params)
      redirect_to @bingo_game, notice: 'Bingo Game was successfully updated.'
    else
      render :edit
    end
  end

  def review_candidates
    @title = t '.title'
  end

  def update_review_candidates
    # Process the data
    params_act = params["/bingo/candidates_review/#{@bingo_game.id}"]
    @bingo_game.candidates.completed.each do |candidate|
      code = 'candidate_feedback_' + candidate.id.to_s
      feedback_id = params_act["candidate_feedback_#{candidate.id}"]
      next if feedback_id.blank?
      candidate.candidate_feedback = CandidateFeedback.find(feedback_id)
      candidate.candidate_feedback_id = candidate.candidate_feedback.id
      unless candidate.candidate_feedback.name.start_with? 'Term'
        concept_name = params_act["concept_#{candidate.id}"].split.map(&:capitalize).*' '
        concept = Concept.where(name: concept_name).take
        concept = Concept.create(name: concept_name) if concept.nil?
        candidate.concept = concept
      end
      candidate.save
      logger.debug candidate.errors.full_messages unless candidate.errors.empty?
    end

    @bingo_game.reviewed = params_act['reviewed']
    if @bingo_game.reviewed && !@bingo_game.students_notified
      @bingo_game.course.enrolled_students.each do |student|
        AdministrativeMailer.notify_availability(student,
                                                 "#{@bingo_game.topic} terms list").deliver_later
      end
      @bingo_game.students_notified = true
    end
    @bingo_game.save
    logger.debug @bingo_game.errors.full_messages unless @bingo_game.errors.empty?

    if @bingo_game.errors.empty? && @bingo_game.reviewed
      redirect_to root_url, notice: (t 'bingo_games.review_success')
    elsif !@bingo_game.errors.empty?
      redirect_to :review_bingo_candidates, notice: (t 'bingo_games.review_problems')
    else
      redirect_to :review_bingo_candidates, notice: (t 'bingo_games.review_success')
    end
  end

  def destroy
    @course = @bingo_game.course
    @bingo_game.destroy
    redirect_to @course, notice: (t 'bingo_games.destroy_success')
  end

  def activate
    bingo_game = BingoGame.find(params[:bingo_game_id])
    if @current_user.is_admin? ||
       bingo_game.course.get_roster_for_user(@current_user).role.name == 'Instructor'
      bingo_game.active = true
      bingo_game.save
    end
    @bingo_game = bingo_game
    @title = t '.title'
    render :show, notice: (t 'bingo_games.activate_success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bingo_game
    bg_test = BingoGame.find(params[:id])
    if @current_user.is_admin?
      @bingo_game = bg_test
    else
      @course = bg_test.course
      if bg_test.course.rosters.instructorships.where(user: @current_user).nil?
        redirect_to @course if @bingo_game.nil?
      else
        @bingo_game = bg_test
      end
    end
  end

  def check_admin
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def bingo_game_params
    params.require(:bingo_game).permit(:course_id, :topic, :description, :link, :source,
                                       :group_option, :individual_count, :group_discount,
                                       :lead_time, :project_id, :start_date, :end_date)
  end
end
