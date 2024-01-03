# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show edit update destroy status]
  include PermissionsCheck

  before_action :check_editor, except: :status

  before_action :check_admin, only: :index

  # GET /assignments or /assignments.json
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1/status or /assignments/1/status.json
  def status
    # TODO: Check if course owner
    response = standardized_response(@assignment)
    response[:rubric] = @assignment.rubric.as_json(
      include: { criteria: {
        only: %i[ id description weight sequence
                  l1_description l2_description l3_description l4_description l5_description ]
      } },
      only: %i[id name description version]
    )
    submissions = []
    if current_user.is_admin? || @assignment.course.rosters.instructor.include?(current_user)
      submissions = @assignment.submissions.includes(:user)
    elsif @assignment.group_enabled
      group = @assignment.project.group_for_user(current_user)

      submissions = @assignment.submissions.includes(:user).where(group:)
    else
      submissions = @assignment.submissions.includes(:user).where(user: current_user)
    end

    anon = current_user.anonymize?
    o_submissions = []
    submissions.each do |submission|
      o_submissions << {
        id: submission.id,
        submitted: submission.submitted,
        withdrawn: submission.withdrawn,
        recorded_score: submission.recorded_score || submission.calculated_score,
        user: current_user.name(anon)
      }
    end

    response[:submissions] = o_submissions.as_json

    respond_to do |format|
      format.json do
        render json: response
      end
    end
  end

  # GET /assignments/1 or /assignments/1.json
  def show
    # TODO: Check if course owner
    respond_to do |format|
      format.json do
        render json: standardized_response(@assignment)
      end
    end
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit; end

  # POST /assignments or /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)

    respond_to do |format|
      if @assignment.save
        format.json do
          render json: standardized_response(@assignment, { main: I18n.t('assignments.errors.no_create_error') })
        end
      else
        errors = @assignment.errors
        errors.add(:main, I18n.t('assignments.errors.create_failed'))
        Rails.logger.debug @assignment.inspect
        Rails.logger.debug @assignment.errors.full_messages
        format.json { render json: standardized_response(@assignment, @assignment.errors) }
      end
    end
  end

  # PATCH/PUT /assignments/1 or /assignments/1.json
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.json do
          render json: standardized_response(@assignment, { main: I18n.t('assignments.errors.no_update_error') })
        end
      else
        errors = @assignment.errors
        errors.add(:mail, I18n.t('assignments.errors.update_failed'))
        Rails.logger.debug @assignment.errors.full_messages
        format.json { render json: standardized_response(@assignment, @assignment.errors) }
      end
    end
  end

  private

  def standardized_response(assignment, messages = {})
    anon = current_user.anonymize?
    response = {
      assignment: assignment.as_json(
        only: %i[id start_date end_date
                 rubric_id group_enabled project_id
                 text_sub file_sub link_sub
                 active]
      )
    }
    response[:assignment][:name] = anon ? assignment.anon_name : assignment.name
    response[:assignment][:description] = anon ? assignment.anon_description : assignment.description

    response[:assignment][:course] = {
      timezone: ActiveSupport::TimeZone.new(assignment.course.timezone).tzinfo.name
    }
    response[:projects] = assignment.course.projects.as_json(
      only: %i[id name]
    )
    rubrics = if current_user.is_admin?
                Rubric.for_admin
              else
                Rubric.for_instructor(current_user)
              end
    response[:rubrics] = rubrics.as_json(only: %i[id name version])
    response[:messages] = messages

    response
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    if params[:id].blank?
      course = Course.find params[:course_id]
      @assignment = course.assignments.new(
        course_id: params[:course_id],
        start_date: course.start_date,
        end_date: course.end_date
      )
    else
      @assignment = Assignment.find(params[:id])
    end
  end

  # Only allow a list of trusted parameters through.
  def assignment_params
    params.require(:assignment).permit(:name, :description, :start_date, :end_date, :rubric_id, :group_enabled,
                                       :file_sub, :link_sub, :text_sub,
                                       :course_id, :project_id, :active)
  end
end
