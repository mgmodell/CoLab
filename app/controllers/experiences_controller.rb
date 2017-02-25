class ExperiencesController < ApplicationController
  before_action :set_experience, only: [:show, :edit, :update, :destroy]
  before_action :check_admin, except: [:next, :diagnose, :react]

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

    experience = Experience.still_open.joins(course: { rosters: :user })
                           .where(users: { id: @current_user }).take

    if experience.nil?
      redirect_to '/', notice: 'That Experience is a part of another course'
    else
      reaction = experience.get_user_reaction(@current_user)
      week = reaction.next_week
      if !reaction.instructed?
        reaction.instructed = true
        reaction.save
        @experience = experience
        render :studyInstructions
      else
        if week.nil?
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
    @reaction = Reaction.new(params[reaction: :id])
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

  def check_admin
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
