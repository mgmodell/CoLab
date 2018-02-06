# frozen_string_literal: true

class ExperiencesController < ApplicationController
  before_action :set_experience, only: %i[show edit update destroy]
  before_action :check_viewer, only: %i[show index]
  before_action :check_editor, only: %i[edit update destroy]

  def show
    @title = t('.title')
  end

  def edit
    @title = t('.title')
  end

  def index
    @title = t('.title')
    @experiences = []
    if @current_user.is_admin?
      @experiences = Experience.all
    else
      rosters = @current_user.rosters.instructor
      rosters.each do |roster|
        @experiences.concat roster.course.experiences.to_a
      end
    end
  end

  def new
    @title = t('.title')
    @experience = Course.find(params[:course_id]).experiences.new
    @experience.start_date = @experience.course.start_date
    @experience.end_date = @experience.course.end_date
  end

  def create
    @experience = Experience.new(experience_params)
    @experience.course = Course.find(@experience.course_id)
    if @experience.save
      redirect_to @experience, notice: t('experiences.create_success')
    else
      puts @experience.errors.full_messages unless @experience.errors.empty?
      @title = t('experiences.new.title')
      render :new
    end
  end

  def update
    if @experience.update(experience_params)
      redirect_to @experience, notice: t('experiences.update_success')
    else
      puts @experience.errors.full_messages unless @experience.errors.empty?
      @title = t('experiences.edit.title')
      render :edit
    end
  end

  def destroy
    @course = @experience.course
    @experience.destroy
    redirect_to @course, notice: t('experiences.destroy_success')
  end

  # Maybe build in JSON API support
  def next
    experience_id = params[:experience_id]

    experience = Experience.joins(course: { rosters: :user })
                           .where(id: experience_id, users: { id: @current_user }).take

    if experience.nil? && !experience.is_open
      redirect_to '/', notice: t('experiences.wrong_course')
    else
      reaction = experience.get_user_reaction(@current_user)
      week = reaction.next_week
      if !reaction.instructed?
        reaction.instructed = true
        reaction.save
        @experience = experience
        @title = t('experiences.instr_title')
        render :instructions
      else
        if week.nil?
          @reaction = reaction
          # we just finished the last week
          @title = t('experiences.react_title')
          render :reaction
        else
          @diagnosis = reaction.diagnoses.new(week: week)
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
      @diagnosis = reaction.diagnoses.new(week: week)
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
        format.html { redirect_to root_path, notice: t('experiences.react_success') }
        format.json { render :show, status: :ok, location: @reaction }
      else
        format.html { render :reaction, notice: t('experiences.react_fail') }
        format.json { render json: @reaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    experience = Experience.find(params[:experience_id])
    if @current_user.is_admin? ||
       experience.course.get_roster_for_user(@current_user).role.instructor?
      experience.active = true
      experience.save
    end
    @experience = experience
    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_experience
    e_test = Experience.find(params[:id])
    if @current_user.is_admin?
      @experience = e_test
    else
      @experience = e_test
      @course = @experience.course
      if e_test.course.rosters.instructor.where(user: @current_user).nil?
        redirect_to @course if @experience.nil?
      else
        @experience = e_test
      end
    end
  end

  def check_viewer
    redirect_to root_path unless @current_user.is_admin? ||
                                 @current_user.is_instructor? ||
                                 @current_user.is_researcher?
  end

  def check_editor
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def experience_params
    params.require(:experience).permit(:course_id, :name, :active, :start_date, :end_date)
  end

  def diagnosis_params
    params.require(:diagnosis).permit(:behavior_id, :reaction_id, :week_id, :other_name,
                                      :comment, :reaction_id)
  end

  def reaction_params
    params.require(:reaction).permit(:behavior_id, :improvements, :narrative_id, :other_name)
  end
end
