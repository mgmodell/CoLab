# frozen_string_literal: true

class ConsentLogsController < ApplicationController
  def update
    @title = t('consent_logs.title')
    @consent_log = ConsentLog.find(params[:id])

    @consent_log.accepted = params[:consent_log][:accepted]
    @consent_log.presented = true

    if @consent_log.save!
      messages = { main: t('consent_logs.save_success') }
    else
      messages = @consent_log.errors.as_json
      messages[:main] = 'Please review the problems below'
    end

    respond_to do |format|
      format.json do
        render json: {
          consent_log: @consent_log.as_json(
            only: %i[id accepted]
          ),
          messages:
        }
      end
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

    # Supporting the JSON API
    respond_to do |format|
      format.json do
        render json: {
          consent_log: {
            id: @consent_log.id,
            consent_form_id: @consent_form.id,
            name: @consent_form.name,
            accepted: @consent_log.accepted,
            presented: @consent_log.presented,
            updatedAt: @consent_log.updated_at,
            formText: @consent_form.form_text,
            pdfLink: url_for(@consent_form.pdf)
          }
        }
      end
    end
  end

  def user_logs
    resp = current_user.consent_logs.collect do |consent_log|
      {
        id: consent_log.id,
        name: consent_log.consent_form_name,
        accepted: consent_log.accepted,
        active: consent_log.consent_form_active,
        open_date: consent_log.consent_form_start_date,
        end_date: consent_log.consent_form_end_date,
        link: edit_consent_log_path(consent_log.consent_form_id)
      }
    end
    respond_to do |format|
      format.json { render json: resp }
    end
  end

  private

  def cl_params
    params.require(:consent_log).permit(:accepted, :presented)
  end
end
