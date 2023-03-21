class SubmissionFeedbacksController < ApplicationController
  before_action :set_submission_feedback, only: %i[ show edit update destroy ]

  # GET /submission_feedbacks or /submission_feedbacks.json
  def index
    @submission_feedbacks = SubmissionFeedback.all
  end

  # GET /submission_feedbacks/1 or /submission_feedbacks/1.json
  def show
  end

  # GET /submission_feedbacks/new
  def new
    @submission_feedback = SubmissionFeedback.new
  end

  # GET /submission_feedbacks/1/edit
  def edit
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
    # Use callbacks to share common setup or constraints between actions.
    def set_submission_feedback
      @submission_feedback = SubmissionFeedback.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def submission_feedback_params
      params.require(:submission_feedback).permit(:submission_id, :calculated_score, :feedback)
    end
end
