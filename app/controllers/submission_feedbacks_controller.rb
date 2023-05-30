class SubmissionFeedbacksController < ApplicationController
  before_action :set_submission_feedback, only: %i[ show edit update destroy ]

  # GET /assignment/critiques/1 or /assignment/critiques/1.json
  def index_for_assignment
    submissions = Submission.includes(:user, :group).where( assignment_id: params[:id] )
    respond_to do |format|
      format.json do
        render json: {
          submissions: submissions.as_json(
            include: {
              user: {only: %i[ id first_name last_name email]},
              group: { only: [ :id, :name, users: { only: %i[ first_name last_name email ]} ]},
            },
            only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at ]
          ) }
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
        format.html { redirect_to submission_feedback_url(@submission_feedback), notice: "Submission feedback was successfully created." }
        format.json { render :show, status: :created, location: @submission_feedback }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @submission_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submission_feedbacks/1 or /submission_feedbacks/1.json
  def update
    respond_to do |format|
      if @submission_feedback.update(submission_feedback_params)
        format.html { redirect_to submission_feedback_url(@submission_feedback), notice: "Submission feedback was successfully updated." }
        format.json { render :show, status: :ok, location: @submission_feedback }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @submission_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submission_feedbacks/1 or /submission_feedbacks/1.json
  def destroy
    @submission_feedback.destroy

    respond_to do |format|
      format.html { redirect_to submission_feedbacks_url, notice: "Submission feedback was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def standardized_response( submission, messages = {} )
      puts submission.rubric.inspect
      response = {
        submission: submission.as_json(
          include: {
            rubric: {
              only: %I[id name description published active school_id version parent_id],
              include: { criteria: { only: %I[ id description sequence
                                               weight l1_description l2_description
                                               l3_description l4_description l5_description ] } }
            },
            user: {only: %i[ first_name last_name email]},
            group: { only: [ :name, users: { only: %i[ first_name last_name email ]} ]},
            submission_feedback: { only: %I[ id calculated_score feedback],
              include: {
                rubric_row_feedbacks: { only: %I[id submission_feedback_id score feedback criterium_id]}
              }},

          },
          only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at ]
        )
      }
      response[:messages] = messages
      response
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_submission_feedback
      return_value = nil

      @submission = Submission
        .includes( rubric: :criteria, submission_feedback: :rubric_row_feedbacks )
        .find( params[:submission_id])

      #return value
      @submission
      
    end

    # Only allow a list of trusted parameters through.
    def submission_feedback_params
      params.require(:submission_feedback).permit(:submission_id, :feedback,
                                                rubric_row_feedbacks_attributes: %I[id 
                                                submission_feedback_id score feedback criterium_id]
      )
    end
end
