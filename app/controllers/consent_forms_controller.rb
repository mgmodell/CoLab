# frozen_string_literal: true

class ConsentFormsController < ApplicationController
  before_action :set_consent_form, only: %i[show edit update destroy]

  # GET /consent_forms
  # GET /consent_forms.json
  def index
    @consent_forms = ConsentForm.all
    respond_to do |format|
      format.json do
        resp = @consent_forms.collect do |cf|
          {
            id: cf.id,
            name: cf.name,
            active: cf.active
          }
        end
        render json: resp
      end
    end
  end

  # GET /consent_forms/1
  # GET /consent_forms/1.json
  def show
    respond_to do |format|
      format.json do
        response = {
          consent_form: @consent_form.as_json(
            only: %i[ id name start_date end_date active
                      form_text_en form_text_ko ]
          ),
          messages: {}
        }
        render json: response
      end
    end
  end

  # GET /consent_forms/1/edit
  def edit; end

  # POST /consent_forms
  # POST /consent_forms.json
  def create
    @consent_form = ConsentForm.new(consent_form_params)
    respond_to do |format|
      if @consent_form.save
        notice = 'Consent form was successfully created.'
        format.json do
          response = {
            consent_form: @consent_form.as_json(
              only: %i[ id name start_date end_date active
                        form_text_en form_text_ko ]
            ),
            messages: { main: notice }
          }
          render json: response
        end
      else
        logger.debug @consent_form.errors.full_messages unless @consent_form.errors.empty?
        format.json do
          messages = @consent_form.errors.as_json
          messages[:main] = 'Please review the problems below'
          render json: {
            messages:
          }
        end
      end
    end
  end

  # PATCH/PUT /consent_forms/1
  # PATCH/PUT /consent_forms/1.json
  def update
    if @consent_form.update(consent_form_params)
      notice = 'Consent form was successfully updated.'
      respond_to do |format|
        format.json do
          response = {
            consent_form: @consent_form.as_json(
              only: %i[ id name start_date end_date active
                        form_text_en form_text_ko ]
            ),
            messages: { main: notice }
          }
          render json: response
        end
      end
    else
      logger.debug @consent_form.errors.full_messages unless @consent_form.errors.empty?
      respond_to do |format|
        format.json do
          messages = @consent_form.errors.to_hash
          messages[:main] = 'Please review the problems below.'
          response = {
            messages:
          }
          render json: response
        end
      end
    end
  end

  # DELETE /consent_forms/1
  # DELETE /consent_forms/1.json
  def destroy
    @consent_form.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_consent_form
    @consent_form = if params[:id].blank? || 'new' == params[:id]
                      ConsentForm.new
                    else
                      ConsentForm.find(params[:id])
                    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def consent_form_params
    params.require(:consent_form)
          .permit(:name, :user_id, :pdf, :project_ids,
                  :form_text_en, :form_text_ko,
                  :start_date, :end_date, :active)
  end
end
