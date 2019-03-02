# frozen_string_literal: true

class ConsentLogsController < ApplicationController
  def update
    @title = t('consent_logs.title')
    @consent_log = ConsentLog.find(params[:id])
    if @consent_log.update!(cl_params)
      redirect_to controller: 'home', action: 'index'
    else
      logger.debug @consent_log.errors.full_messages unless @consent_log.errors.empty?
      render action: 'edit'
    end
  end

  def edit
    @title = t('consent_logs.title')
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
    params.require(:consent_log).permit(:accepted, :presented)
  end
end
