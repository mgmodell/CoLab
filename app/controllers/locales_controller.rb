# frozen_string_literal: true

class LocalesController < ApplicationController
  skip_before_action :authenticate_user!

  def get_resources
    ns = params[:ns]
    lng = params[:lng]

    texts = if 'base' == ns
              I18n.t '.', locale: lng
            else
              I18n.t ns, locale: lng
            end

    render json: texts
  end
end
