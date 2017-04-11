# frozen_string_literal: true
class BingoGamesController < ApplicationController
  before_action :set_bingo_game, only: [:show, :edit, :update, :destroy, :review_candidates]
  before_action :check_admin, except: [:next, :diagnose, :react]

  def show; end

  def edit; end

  def index
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
    @bingo_game = BingoGame.new
    @bingo_game.course_id = params[:course_id]
    @bingo_game.course = Course.find(params[:course_id])
    @bingo_game.start_date = @bingo_game.course.start_date
    @bingo_game.end_date = @bingo_game.course.end_date
  end

  def create
    @bingo_game = BingoGame.new(bingo_game_params)
    respond_to do |format|
      if @bingo_game.save
        format.html { redirect_to @bingo_game, notice: 'Bingo Game was successfully created.' }
        format.json { render :show, status: :created, location: @bingo_game }
      else
        format.html { render :new }
        format.json { render json: @bingo_game.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bingo_game.update(bingo_game_params)
        format.html { redirect_to @bingo_game, notice: 'Bingo Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @bingo_game }
      else
        format.html { render :edit }
        format.json { render json: @bingo_game.errors, status: :unprocessable_entity }
      end
    end
  end

  def review_candidates
  end

  def update_candidate_review
    respond_to do |format|
      if @bingo_game.update(candidate_review_params)
        if @bingo_game.reviewed
          format.html { redirect_to root_path, 'Review was successfully saved and completed.' }
        else
          format.html { redirect_to @bingo_game, notice: 'Review was successfully saved.' }
        end
      else
        format.html { render :review_candidates }
      end
    end

  end

  def destroy
    @course = @bingo_game.course
    @bingo_game.destroy
    respond_to do |format|
      format.html { redirect_to @course, notice: 'Bingo Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def activate
    bingo_game = BingoGame.find(params[:bingo_game_id])
    if @current_user.is_admin? ||
       bingo_game.course.get_roster_for_user(@current_user).role.name == 'Instructor'
      bingo_game.active = true
      bingo_game.save
    end
    @bingo_game = bingo_game
    render :show
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

  def candidate_review_params
    params.require(:bingo_game).permit(:course_id, candidate_lists: [ candidates: [ :candidate_feedback, :concept ] ] )
  end
end
