class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[show update ]


  # GET /submissions/1 or /submissions/1.json
  def show
    # TODO: Check if owner or course owner
    respond_to do |format|
      format.json do
        render json: standardized_response(@submission)
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    puts "update: #{@submission.inspect}"
    puts "submit? #{params[:submit]}"

    @submission.user = current_user
    if @submission.update( submission_params )
      respond_to do |format|

      # if @submission.update(submission_params)
        format.json do
          render json: standardized_response(@submission, { main: I18n.t('assignments.errors.no_update_error') })
        end
      end
    else
      errors = @submission.errors
      errors.add(:mail, I18n.t('submissions.errors.update_failed'))
      logger.debug @submission.errors.full_messages
      respond_to do |format|
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
        assignment: { only: [ :name, :description, :start_date, :end_date, :group_enabled,
                              project: { only: %i[ name ] },
                              rubric: { only: [ :name, :description, :version,
                                  criteria: { only: %i[ description weight sequence
                                                        l1_description l2_description
                                                        l3_description l4_description l5_description]}]}]},
        only: %i[id submitted withdrawn recorded_score sub_text sub_link updated_at ]
      )
    }
    response[:messages] = messages
    response

  end

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    submission_id = params[:id].to_i


    @submission = if 0 < submission_id
                    Submission.where(
                        user_id: @current_user,
                        id: submission_id,
                    ).take
                  else
                    Submission.new(
                      user: @current_user
                    )
                  end
  end

  # Only allow a list of trusted parameters through.
  def submission_params
    params.require(:submission).permit( :sub_file, :sub_text, :sub_link, :assignment_id )
  end
end
