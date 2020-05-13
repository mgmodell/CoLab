# frozen_string_literal: true

class ConsentLogsController < ApplicationController
  def update
    @title = t('consent_logs.title')
    @consent_log = ConsentLog.find(params[:id])
    if @consent_log.update!(cl_params)
      redirect_to controller: 'home', action: 'index'
    else
      unless @consent_log.errors.empty?
        logger.debug @consent_log.errors.full_messages
      end
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

  def user_logs
    resp = current_user.consent_logs.collect{|consent_log|
      {
        id: consent_log.id,
        name: consent_log.consent_form.name,
        accepted: consent_log.accepted,
        active: consent_log.consent_form.active,
        open_date: consent_log.consent_form.start_date,
        end_date: consent_log.consent_form.end_date,
        link: edit_consent_log_path( consent_log.consent_form_id )
      }
  
    }
    respond_to do |format|
      format.json { render json: resp }
    end
  end

  private

  def cl_params
    params.require(:consent_log).permit(:accepted, :presented)
  end
end
