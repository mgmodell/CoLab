# frozen_string_literal: true

class SubmissionFeedbacksController < ApplicationController
  include PermissionsCheck

  before_action :set_submission, only: %i[show edit]
  before_action :set_submission_feedback, only: %i[update destroy]
  before_action :check_editor

  # GET /assignment/critiques/1 or /assignment/critiques/1.json
  def index_for_assignment
    assignment = Assignment.includes(submissions: %i[user group]).find(params[:id])
    respond_to do |format|
      format.json do
        render json: {
          assignment: assignment.as_json(
            include: {
              submissions: {
                include: {
                  user: { only: %i[id first_name last_name email] },
                  group: { only: [:id, :name, { users: { only: %i[first_name last_name email] } }] }
                },
                only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at],
                methods: :calculated_score

              }

            },
            only: %i[id name file_sub link_sub text_sub group_enabled]
          )
        }
      end
    end
  end

  # GET /submission_feedbacks/1 or /submission_feedbacks/1.json
  def show
    @submission.rubric = @submission.assignment.rubric if @submission.rubric_id.nil?

    respond_to do |format|
      format.json do
        render json: standardized_response(@submission)
      end
    end
  end

  # POST /submission_feedbacks or /submission_feedbacks.json
  def create
    @submission_feedback = SubmissionFeedback.new(submission_feedback_params)

    respond_to do |format|
      if @submission_feedback.save
        format.json { render :show, status: :created, location: @submission_feedback }
      else
        format.json { render json: @submission_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignment/critique/1 or /assignment/critique/1.json
  def update
    @submission_feedback.transaction do
      submission = @submission_feedback.submission
      @submission_feedback.assign_attributes(submission_feedback_params) if @submission_feedback.id.present?
      submission.recorded_score = params[:override_score]

      respond_to do |format|
        if @submission_feedback.save && submission.save
          format.json  do
            response = {
              submission_feedback: @submission_feedback.as_json(
                  include: {
                    rubric_row_feedbacks: {
                      only: %i[ id feedback score submission_feedback_id criterium_id]
                    }
                  },
                  only: %i[ id submission_id feedback]
                ),
              messages: {
                main: t('critiques.save_success_msg'),

              }
            }
            render json: response
          end
        else

          errors = @submission_feedback.errors.to_hash.merge( submission.errors.to_hash )
          errors[:main] = t('critiques.save_fail_msg') unless errors[:main].present?

          response = {
            messages: errors
          }
          format.json do
            render json: response
          end
          
        end
      end
    end
  end

  # DELETE /submission_feedbacks/1 or /submission_feedbacks/1.json
  def destroy
    @submission_feedback.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def standardized_response(submission, messages = {})
    response = {
      submission: submission.as_json(
        include: {
          rubric: {
            only: %I[id name description published active school_id version parent_id],
            include: { criteria: { only: %I[ id description sequence
                                             weight l1_description l2_description
                                             l3_description l4_description l5_description ] } }
          },
          user: { only: %i[first_name last_name email] },
          group: { only: [:name, { users: { only: %i[first_name last_name email] } }] },
          submission_feedback: { only: %I[id feedback],
                                 include: {
                                   rubric_row_feedbacks: { only: %I[id submission_feedback_id score feedback
                                                                    criterium_id] }
                                 } }

        },
        only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at],
        methods: :calculated_score
      )
    }
    response[:messages] = messages
    response
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_submission_feedback
    if params[:submission_feedback_id].to_i > 0
      @submission_feedback = SubmissionFeedback
                    .includes( :rubric_row_feedbacks)
                    .find(params[:submission_feedback_id])
    else
      @submission_feedback = SubmissionFeedback.new(
        submission_feedback_params
      )

    end

    @submission_feedback
  end

  def set_submission
    @submission = Submission
                  .includes(rubric: :criteria, submission_feedback: :rubric_row_feedbacks)
                  .find(params[:submission_id])

    @submission
  end

  # Only allow a list of trusted parameters through.
  def submission_feedback_params
    params.require(:submission_feedback).permit(:submission_id, :feedback, 
                                                rubric_row_feedbacks_attributes: %I[id
                                                                                    submission_feedback_id score feedback criterium_id])
  end
end
