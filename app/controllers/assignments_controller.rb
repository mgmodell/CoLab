class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show edit update destroy]
  include PermissionsCheck

  before_action :check_editor

  before_action :check_admin, only: :index

  # GET /assignments or /assignments.json
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1 or /assignments/1.json
  def show
    #TODO: Check if course owner
    anon = current_user.anonymize?
    respond_to do |format|
      format.json do
        render json: standardized_response( @assignment )
      end
    end
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments or /assignments.json
  def create
    @assignment = Assignment.new(assignment_params)

    respond_to do |format|
      if @assignment.save
        render json: standardized_response( @assignment )
      else
        puts @assignment.errors.full_messages
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1 or /assignments/1.json
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        render json: standardized_response( @assignment, {main: 'Successfully saved assignment'})
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1 or /assignments/1.json
  def destroy
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to assignments_url, notice: "Assignment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  def standardized_response assignment, messages = {}
    anon = current_user.anonymize?
        response = {
          assignment: assignment.as_json(
              only: [:id, :start_date, :end_date,
                :rubric_id, :group_enabled, :project_id,
                :active ]
            )
          }
        response[:assignment][:name] = anon ? assignment.name : assignment.anon_name
        response[:assignment][:description] = anon ? assignment.description : assignment.anon_description

        response[:assignment][:course] = {
          timezone: ActiveSupport::TimeZone.new( assignment.course.timezone ).tzinfo.name
        }
        response[:projects] = assignment.course.projects.as_json(
          only: [:id, :name ]
        )
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
      params.require(:assignment).permit(:name, :description, :open, :close, :rubric_id, :group_enabled, :course_id, :project_id, :active)
    end
end
