class LocalesController < ApplicationController

  def get_resources
    lang = params[:lang]
    ns = params[:ns]
    lang_was = I18n.locale
    I18n.locale = lang
    texts = I18n.t ns 
    I18n.locale = lang_was

    render json: texts
  end
end
