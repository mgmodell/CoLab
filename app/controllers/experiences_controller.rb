class ExperiencesController < ApplicationController
  before_action :set_experience, only: [:show, :edit, :update, :destroy]

  def show; end

  def edit; end

  def index
    @experiences = []
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
    @experience.destroy
    respond_to do |format|
      format.html { redirect_to experiences_url, notice: 'Experience was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def next
    experience_id = params[:experience_id]

    @experience = Experience.still_open.joins(course: { rosters: :user })
                            .where(users: { id: @current_user }).take

    if @experience.nil?
      redirect_to '/', notice: 'That Experience is a part of another course'
    else
      @reaction = @experience.get_user_reaction(@current_user)
      if !@reaction.persisted?
        @reaction.next_week
        @reaction.save
        render :studyInstructions
      else
        week = @reaction.next_week
        if week.nil?
          # we just finished the last week
          render :reaction
        end
        @diagnosis = Diagnosis.new(reaction: @reaction, week: week)
      end
    end
  end

  def diagnose
    diagnosis = Diagnosis.new(diagnosis_params)
    exp_id = Reaction.find(diagnosis.reaction_id).experience_id
    diagnosis.save
    flash[ :error ] = diagnosis.errors
    flash.keep
    redirect_to next_experience_path(experience_id: exp_id)
  end

  def react
    # TODO: record a reaction
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_experience
    e_test = Experience.find(params[:id])
    if @current_user.is_admin?
      @experience = e_test
    else
      if e_test.course.rosters.instructorships.where(user: @current_user).nil?
        redirect_to :show if @experience.nil?
      else
        @experience = e_test
      end
    end
  end

  def experience_params
    params.require( :experience ).permit( :course_id, :name, :active, :start_date, :end_date)
  end

  def diagnosis_params
    params.require( :diagnosis ).permit( :behavior_id, :reaction_id, :week_id, :other_name, 
                                        :comment_text, :reaction_id)
  end
end
