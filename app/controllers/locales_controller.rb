# frozen_string_literal: true

class LocalesController < ApplicationController
  def get_resources
    ns = params[:ns]
    if 'base' == ns
      texts = I18n.t '.'
    else
      texts = I18n.t ns
    end

    render json: texts
  end
end
