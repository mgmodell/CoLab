# frozen_string_literal: true

class LocalesController < ApplicationController
  def get_resources
    ns = params[:ns]
    texts = I18n.t ns

    render json: texts
  end
end
