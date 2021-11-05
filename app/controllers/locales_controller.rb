# frozen_string_literal: true

class LocalesController < ApplicationController
  skip_before_action :authenticate_user!

  def get_resources
  puts "*******"
  puts "\tparams: #{params[:ns]}"
  puts "\tlocale: #{I18n.locale}"
    ns = params[:ns]
    texts = if ns == 'base'
              I18n.t '.'
            else
              I18n.t ns
            end

    puts "#{texts}"
  puts "*************"
    render json: texts
  end
end
