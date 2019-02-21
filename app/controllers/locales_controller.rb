class LocalesController < ApplicationController

  def get_resources
    ns = params[:ns]
    lang = params[:lang]

    #TODO: build a more robust solution
    if @current_user.present?
      lang = @current_user.language.code
    else
      lang = 'en'
    end

    I18n.locale = lang
    texts = I18n.t ns 

    render json: texts
  end
end
