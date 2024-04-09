# frozen_string_literal: true

class SchoolsController < ApplicationController
  include PermissionsCheck

  before_action :set_school, only: %i[show update destroy]
  before_action :check_admin

  def show
    respond_to do |format|
      format.json do
        response = {
          school: @school.as_json(
            only: %i[id name description timezone]
          ),
          timezones: HomeController::TIMEZONES,
          messages: {}
        }
        render json: response
      end
    end
  end

  # GET /admin/school
  def index
    schools = School.all
    anon = current_user.anonymize?
    respond_to do |format|
      format.json do
        resp = schools.collect do |school|
          {
            id: school.id,
            name: school.get_name(anon),
            courses: school.courses.size,
            students: school.enrolled_students.size,
            instructors: school.instructors.size,
            projects: school.projects.size,
            experiences: school.projects.size,
            terms_lists: school.bingo_games.size
          }
        end
        render json: resp
      end
    end
  end

  def create
    @school = School.new(school_params)
    if @school.save
      notice = t('schools.create_success')
      respond_to do |format|
        format.json do
          response = {
            school: @school.as_json(
              only: %i[id name description timezone]
            ),
            messages: { main: notice }
          }
          render json: response
        end
      end
    else
      logger.debug @school.errors.full_messages unless @school.errors.empty?
      respond_to do |format|
        format.json do
          messages = @school.errors.as_json
          messages[:main] = 'Please review the problems below'
          render json: {
            messages:
          }
        end
      end
    end
  end

  def update
    if @school.update(school_params)
      notice = t('schools.update_success')
      respond_to do |format|
        format.json do
          response = {
            school: @school.as_json(
              only: %i[id name description timezone]
            ),
            messages: { main: notice }
          }
          render json: response
        end
      end
    else
      logger.debug @school.errors.full_messages
      respond_to do |format|
        format.json do
          messages = @school.errors.to_hash
          messages.store(:main, 'Unable to save. Please resolve the issues and try again.')
          response = {
            messages:
          }
          render json: response
        end
      end
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_url, notice: t('schools.destroy_success')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = if params[:id].blank? || 'new' == params[:id]
                School.new(
                  timezone: current_user.timezone
                )
              else
                School.find(params[:id])
              end
  end

  def school_params
    params.require(:school).permit(:name, :description, :timezone)
  end
end
