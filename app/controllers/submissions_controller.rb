# frozen_string_literal: true

class SubmissionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[demo_withdraw show_demo]
  before_action :set_submission, only: %i[show update withdraw]

  include Demoable

  # GET /submissions/1 or /submissions/1.json
  def show
    # TODO: Check if owner or course owner
    respond_to do | format |
      format.json do
        render json: standardized_response( @submission )
      end
    end
  end

  def show_demo
    id = params[:id].to_i
    submission = get_demo_submission( id )
    assignment = get_demo_assignment
    response = {
      submission: {
        id: submission.id,
        submitted: submission.submitted,
        withdrawn: submission.withdrawn,
        recorded_score: submission.recorded_score || submission.calculated_score,
        user: demo_user,
        group: get_demo_group,
        calculated_score: submission.calculated_score,
        sub_text: submission.sub_text,
        sub_link: submission.sub_link,
        assignment: assignment
      }
    }
    respond_to do | format |
      format.json do
        render json: response
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    sub_params = submission_params
    assignment = Assignment.find sub_params[:assignment_id]

    @submission.user = current_user
    @submission.rubric_id = assignment.rubric_id
    if assignment.group_enabled
      group = assignment.project.group_for_user( current_user )
      @submission.group = group
    end
    # Set this as submitted if requested
    unless @submission.submitted.nil?
      # Make a copy of the submission
      new_copy = @submission.dup
      new_copy.id = nil
      new_copy.submitted = nil
      new_copy.withdrawn = nil
      new_copy.recorded_score = nil
      @submission = new_copy
    end


    @submission.submitted = DateTime.now if params[:submit]

    if @submission.update( sub_params )
      respond_to do | format |
        # if @submission.update(submission_params)
        format.json do
          render json: standardized_response( @submission, { main: I18n.t( 'submissions.error.no_update_error' ) } )
        end
      end
    else
      errors = @submission.errors
      errors.add( :main, I18n.t( 'submissions.error.update_failed' ) )
      logger.debug @submission.errors.full_messages
      respond_to do | format |
        format.json { render json: standardized_response( @submission, @submission.errors ) }
      end
    end
  end

  # PATCH/PUT /submissions/withdraw/1 or /submissions/withdraw/1.json
  def withdraw
    @submission.withdrawn = DateTime.now
    if @submission.save
      respond_to do | format |
        format.json do
          render json: standardized_response( @submission, { main: I18n.t( 'submissions.error.no_update_error' ) } )
        end
      end

    else
      respond_to do | format |
        format.json { render json: standardized_response( @submission, @submission.errors ) }
      end

    end
  end

  def demo_withdraw; end

  private

  def standardized_response( submission, messages = {} )
    response = {
      submission: submission.as_json(
        user: { only: %i[first_name last_name email] },
        group: { only: [:name, { users: { only: %i[first_name last_name email] } }] },
        assignment: { only: [:name, :description, :start_date, :end_date, :group_enabled,
                             { project: { only: %i[name] },
                               rubric: { only: [:name, :description, :version,
                                                { criteria: { only: %i[ description weight sequence
                                                                        l1_description l2_description
                                                                        l3_description l4_description l5_description] } }] } }] },
        only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at],
        methods: :calculated_score
      )
    }
    response[:messages] = messages
    response
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    submission_id = params[:id].to_i

    @submission = if submission_id.positive?
                    temp_submission = Submission.find_by id: submission_id
                    temp_submission.can_edit?( @current_user ) ? temp_submission : nil
                  else
                    Submission.new(
                      user: @current_user,
                      creator: @current_user
                    )
                  end
  end

  # Only allow a list of trusted parameters through.
  def submission_params
    params.require( :submission ).permit( :sub_file, :sub_text, :sub_link, :assignment_id )
  end
end
