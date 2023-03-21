class RubricRowFeedbacksController < ApplicationController
  before_action :set_rubric_row_feedback, only: %i[ show edit update destroy ]

  # GET /rubric_row_feedbacks or /rubric_row_feedbacks.json
  def index
    @rubric_row_feedbacks = RubricRowFeedback.all
  end

  # GET /rubric_row_feedbacks/1 or /rubric_row_feedbacks/1.json
  def show
  end

  # GET /rubric_row_feedbacks/new
  def new
    @rubric_row_feedback = RubricRowFeedback.new
  end

  # GET /rubric_row_feedbacks/1/edit
  def edit
  end

  # POST /rubric_row_feedbacks or /rubric_row_feedbacks.json
  def create
    @rubric_row_feedback = RubricRowFeedback.new(rubric_row_feedback_params)

    respond_to do |format|
      if @rubric_row_feedback.save
        format.html { redirect_to rubric_row_feedback_url(@rubric_row_feedback), notice: "Rubric row feedback was successfully created." }
        format.json { render :show, status: :created, location: @rubric_row_feedback }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rubric_row_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rubric_row_feedbacks/1 or /rubric_row_feedbacks/1.json
  def update
    respond_to do |format|
      if @rubric_row_feedback.update(rubric_row_feedback_params)
        format.html { redirect_to rubric_row_feedback_url(@rubric_row_feedback), notice: "Rubric row feedback was successfully updated." }
        format.json { render :show, status: :ok, location: @rubric_row_feedback }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rubric_row_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rubric_row_feedbacks/1 or /rubric_row_feedbacks/1.json
  def destroy
    @rubric_row_feedback.destroy

    respond_to do |format|
      format.html { redirect_to rubric_row_feedbacks_url, notice: "Rubric row feedback was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rubric_row_feedback
      @rubric_row_feedback = RubricRowFeedback.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rubric_row_feedback_params
      params.require(:rubric_row_feedback).permit(:submissionFeedback_id, :score, :feedback, :criterium_id)
    end
end
