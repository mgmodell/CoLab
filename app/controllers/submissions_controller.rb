class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[show edit update destroy]


  # GET /submissions/1 or /submissions/1.json
  def show
    # TODO: Check if course owner
    respond_to do |format|
      format.json do
        render json: standardized_response(@submission)
      end
    end
  end

  # POST /submissions or /submissions.json
  def create
    @submission = Submission.new(submission_params)

    respond_to do |format|
      if @submission.save
        format.json do
          render json: standardized_response( @submission, { main: I18n.t( 'submissions.errors.no_create_error')})
        end
      else
        errors = @submission.errors
        errors.add(:main, I18n.t('submissions.errors.create_failed'))
        puts @submission.inspect
        puts @submission.errors.full_messages
        format.json { render json: standardized_response(@submission, @submission.errors) }
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    respond_to do |format|
      @submission.assign( submission_params )
      @submission.user = current_user

      if @submission.save
      # if @submission.update(submission_params)
        format.json do
          render json: standardized_response(@submission, { main: I18n.t('assignments.errors.no_update_error') })
        end
      else
        errors = @submission.errors
        errors.add(:mail, I18n.t('submissions.errors.update_failed'))
        puts @submission.errors.full_messages
        format.json { render json: standardized_response(@submission, @submission.errors) }
      end
    end
  end

  private
  
  def standardized_response( submission, messages = {} )
    response = {
      submission: submission.as_json(
        user: {only: %i[ first_name last_name email]},
        group: { only: [ :name, users: { only: %i[ first_name last_name email ]} ]},
        only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at ]
      )
    }
    response[:messages] = messages
    response

  end

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    @submission = Submission.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def submission_params
    params.require(:submission).permit(:assignment_id, :submitted, :withdrawn, :score, :user_id, :group_id,
                                       :sub_file, :sub_text, :sub_link)
  end
end
