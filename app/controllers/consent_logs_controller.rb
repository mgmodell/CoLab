class ConsentLogsController < ApplicationController
  def update
    @consent_log = ConsentLog.find(params[:id])
    if @consent_log.update!(cl_params)
      redirect_to root_url
    else
      render action: 'edit'
    end
  end

  def edit
    # validations here
    cf_id = params[:consent_form_id]
    u_id = current_user.id
    @consent_form = ConsentForm.find(cf_id)
    @consent_log = ConsentLog.where('user_id = ? AND consent_form_id = ?', u_id, cf_id).first
    if @consent_log.nil?
      @consent_log = ConsentLog.create(accepted: false,
                                       user_id: u_id, consent_form_id: cf_id)
    end
  end

  private

  def cl_params
    params.require(:consent_log).permit(:accepted)
  end
end
