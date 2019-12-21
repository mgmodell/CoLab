# frozen_string_literal: true

class LocalesController < ApplicationController
  def get_resources
    ns = params[:ns]
    puts "\n\n\n\t#{params[:ns]}\n"
    puts "#{params}"
    texts = if ns == 'base'
              I18n.t '.'
            else
              I18n.t ns
            end

    render json: texts
  end
end
