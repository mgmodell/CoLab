# frozen_string_literal: true

class ExperiencesController < ApplicationController
  layout 'admin', except: %i[next diagnose react]
  before_action :set_experience, only: %i[show get_reactions edit update destroy]
  before_action :check_viewer, only: %i[show index]
  before_action :check_editor, only: %i[edit get_reactions update destroy]

  def show
    @title = t('.title')
    respond_to do |format|
      format.html { render :show }
      format.json do
        course_hash = {
          id: @experience.course_id,
          name: @experience.course.name,
          timezone: ActiveSupport::TimeZone.new(@experience.course.timezone).tzinfo.name
        }
        response = {
          experience: @experience.as_json(
            only: %i[id name active start_date end_date lead_time]
          ),
          course: course_hash,
          reactionsUrl: @experience.id.nil? ? nil : get_reactions_path(@experience),
          messages: {
            status: params[:notice]
          }
        }
        render json: response
      end
    end
  end

  def get_reactions
    rosters_hash = @experience.course.rosters.students
                              .index_by(&:user_id)

    reactions = Reaction.includes([:behavior, { user: :emails }, { narrative: :scenario }])
                        .where(experience_id: @experience.id, user_id: rosters_hash.values.collect(&:user_id))

    render json: {
      reactions: reactions.collect do |reaction|
        {
          user: {
            email: reaction.user.email,
            name: reaction.user.name(@anon)
          },
          student_status: rosters_hash[reaction.user_id].role,
          status: reaction.status,
          behavior: reaction.behavior.present? ? reaction.behavior.name : 'Incomplete',
          narrative: reaction.narrative.member,
          scenario: reaction.narrative.scenario.name,
          other_name: reaction.other_name,
          improvements: reaction.improvements || ''
        }
      end.as_json
    }
  end

  def edit
    @title = t('.title')
  end

  def index
    @title = t('.title')
    @experiences = []
    if current_user.is_admin?
      @experiences = Experience.all
    else
      rosters = current_user.rosters.instructor
      rosters.each do |roster|
        @experiences.concat roster.course.experiences.to_a
      end
    end
  end

  def create
    @title = t('experiences.new.title')
    @experience = Experience.new(experience_params)
    @experience.course = Course.find(@experience.course_id)
    if @experience.save
      respond_to do |format|
        format.html do
          redirect_to @experience,
                      notice: t('experiences.create_success')
        end
        format.json do
          response = {
            experience: @experience.as_json(
              only: %i[id name active start_date end_date lead_time]
            ),
            course: @experience.course.as_json(
              only: %i[id name timezone]
            ),
            messages: {
              status: t('experiences.create_success')
            }
          }
          render json: response
        end
      end
    else
      unless @experience.errors.empty?
        logger.debug @experience.errors.full_messages
      end
      respond_to do |format|
        format.html do
          render :new
        end
        format.json do
          messages = @experience.errors.to_hash
          messages[:status] = 'Error creating the Experience'
          render json: { messages: messages }
        end
      end
    end
  end

  def update
    @title = t('experiences.edit.title')
    if @experience.update(experience_params)
      respond_to do |format|
        format.html do
          redirect_to @experience, notice: t('experiences.update_success')
        end
        format.json do
          response = {
            experience: @experience.as_json(
              only: %i[id name active start_date end_date lead_time]
            ),
            course: @experience.course.as_json(
              only: %i[id name timezone]
            ),
            messages: {
              status: t('experiences.update_success')
            }
          }
          render json: response
        end
      end
    else
      logger.debug @experience.errors.full_messages @experience.errors.empty?
      respond_to do |format|
        format.html do
          render :edit
        end
        format.json do
          messages = @experience.errors.to_hash
          messages[:status] = 'Error saving the Experience'
          render json: { messages: messages }
        end
      end
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
                           .where(id: experience_id, users: { id: current_user }).take

    response = {
      messages: { }
    }

    if experience.nil? && !experience.is_open
      response[ :messages ][ :main ] = t( 'experiences.wrong_course')

    else
      reaction = experience.get_user_reaction(current_user)
      week = reaction.next_week

      response = response.merge({
        reaction_id: reaction.id,
        instructed: reaction.instructed
      })

      if !reaction.instructed
        reaction.instructed = true
        reaction.save

        logger.debug reaction.errors.full_messages unless reaction.errors.empty?
      elsif !week.nil?
        response = response.merge( {
          week_id: week.id,
          week_num: week.week_num,
          week_text: week.text,
        } )
      end

      respond_to do |format|
        format.json { render json: response.as_json }
      end

    end
  end

  def diagnose
    received_diagnosis = Diagnosis.new(diagnosis_params)
    received_diagnosis.reaction = Reaction.find(received_diagnosis.reaction_id)
    received_diagnosis.save
    unless received_diagnosis.errors.empty?
      logger.debug received_diagnosis.errors.full_messages
    end

    week = received_diagnosis.reaction.next_week
    if received_diagnosis.errors.any?
      @diagnosis = received_diagnosis
    else
      reaction = received_diagnosis.reaction
      @diagnosis = reaction.diagnoses.new(week: week)
    end
    response = {}
    if week.nil?
      # we just finished the last week
      @reaction = received_diagnosis.reaction
      # render :reaction
    else
      response = response.merge({
        week_id: week.id,
          week_num: week.week_num,
          week_text: week.text,
      })
      # render :next
    end

    respond_to do |format|
      format.json {render json: response.as_json }
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
    if current_user.is_admin? ||
       experience.course.get_roster_for_user(current_user).role.instructor?
      experience.active = true
      experience.save
      unless experience.errors.empty?
        logger.debug experience.errors.full_messages
      end
    end
    @experience = experience
    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_experience
    if params[:id].blank? || params[:id] == 'new'
      course = Course.find(params[:course_id])
      e_test = course.experiences.new
      e_test.start_date = course.start_date
      e_test.end_date = course.end_date
    else
      e_test = Experience.find(params[:id])
    end

    if current_user.is_admin?
      @experience = e_test
    else
      @experience = e_test
      @course = @experience.course
      if e_test.course.rosters.instructor.where(user: current_user).nil?
        redirect_to @course if @experience.nil?
      else
        @experience = e_test
      end
    end
  end

  def check_viewer
    redirect_to root_path unless current_user.is_admin? ||
                                 current_user.is_instructor? ||
                                 current_user.is_researcher?
  end

  def check_editor
    unless current_user.is_admin? || current_user.is_instructor?
      redirect_to root_path
    end
  end

  def experience_params
    params.require(:experience).permit(:course_id, :name, :active,
                                       :lead_time, :start_date, :end_date)
  end

  def diagnosis_params
    params.require(:diagnosis).permit(:behavior_id, :reaction_id, :week_id, :other_name,
                                      :comment, :reaction_id)
  end

  def reaction_params
    params.require(:reaction).permit(:behavior_id, :improvements, :narrative_id,
                                     :other_name)
  end
end
