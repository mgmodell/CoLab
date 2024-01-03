# frozen_string_literal: true

class LocalesController < ApplicationController
  skip_before_action :authenticate_user!

  def get_resources
    ns = params[:ns]
    texts = if 'base' == ns
              I18n.t '.'
            else
              I18n.t ns
            end

    render json: texts
  end
end
