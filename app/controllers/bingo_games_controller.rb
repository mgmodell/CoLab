# frozen_string_literal: true
class BingoGamesController < ApplicationController
  before_action :set_experience, only: [:show, :edit, :update, :destroy]
  before_action :check_admin, except: [:next, :diagnose, :react]

  def show; end

  def edit; end

  def index
    @bingo_games = []
    if @current_user.is_admin?
      @experiences = Experience.all
    else
      rosters = @current_user.rosters.instructorships
      rosters.each do |roster|
        @experiences.concat roster.course.experiences.to_a
      end
    end
  end

  def new
    @experience = Experience.new
    @experience.course_id = params[:course_id]
    @experience.course = Course.find(params[:course_id])
    @experience.start_date = @experience.course.start_date
    @experience.end_date = @experience.course.end_date
  end

  def create
    @experience = Experience.new(experience_params)
    @experience.course = Course.find(@experience.course_id)
    respond_to do |format|
      if @experience.save
        format.html { redirect_to @experience, notice: 'Experience was successfully created.' }
        format.json { render :show, status: :created, location: @experience }
      else
        format.html { render :new }
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @experience.update(experience_params)
        format.html { redirect_to @experience, notice: 'Experience was successfully updated.' }
        format.json { render :show, status: :ok, location: @experience }
      else
        format.html { render :edit }
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @course = @experience.course
    @experience.destroy
    respond_to do |format|
      format.html { redirect_to @course, notice: 'Experience was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def next
    experience_id = params[:experience_id]

    experience = Experience.joins(course: { rosters: :user })
                           .where(id: experience_id, users: { id: @current_user }).take

    if experience.nil? && !experience.is_open
      redirect_to '/', notice: 'That experience is a part of another course'
    else
      reaction = experience.get_user_reaction(@current_user)
      week = reaction.next_week
      if !reaction.instructed?
        reaction.instructed = true
        reaction.save
        @experience = experience
        render :instructions
      else
        if week.nil?
          @reaction = reaction
          # we just finished the last week
          render :reaction
        else
          @diagnosis = Diagnosis.new(reaction: reaction, week: week)
        end
      end
    end
  end

  def diagnose
    received_diagnosis = Diagnosis.new(diagnosis_params)
    received_diagnosis.reaction = Reaction.find(received_diagnosis.reaction_id)
    received_diagnosis.save

    week = received_diagnosis.reaction.next_week
    if received_diagnosis.errors.any?
      @diagnosis = received_diagnosis
    else
      reaction = received_diagnosis.reaction
      @diagnosis = Diagnosis.new(reaction: reaction, week: week)
    end
    if week.nil?
      # we just finished the last week
      @reaction = received_diagnosis.reaction
      render :reaction
    else
      render :next
    end
  end

  def react
    reaction_id = params[:reaction][:id]
    @reaction = if reaction_id.blank?
                  Reaction.new
                else
                  Reaction.find(reaction_id)
                end
    respond_to do |format|
      if @reaction.update(reaction_params)
        format.html { redirect_to root_path, notice: 'Your reaction to the experience was recorded' }
        format.json { render :show, status: :ok, location: @reaction }
      else
        format.html { render :reaction, notice: 'There was a problem with your reaction, try again.' }
        format.json { render json: @reaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    experience = Experience.find(params[:experience_id])
    if @current_user.is_admin? ||
       experience.course.get_roster_for_user(@current_user).role.name == 'Instructor'
      experience.active = true
      experience.save
    end
    @experience = experience
    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    g_test = BingoGame.find(params[:id])
    if @current_user.is_admin?
      @bingo_game = b_test
    else
      @course = @bingo_game.course
      if b_test.course.rosters.instructorships.where(user: @current_user).nil?
        redirect_to @course if @bingo_game.nil?
      else
        @bingo_game = b_test
      end
    end
  end

  def check_admin
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def experience_params
    params.require(:bingo_game).permit(:course_id, :topic, :description, :link, :source,
                                       :group_option, :individual_count, :group_count,
                                       :start_date, :end_date)
  end
end
