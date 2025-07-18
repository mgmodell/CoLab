class CPanelController < ApplicationController
  layout false
  before_action :check_editor

  def index
    #Nothing needs done here - all react

  end

  private
  def check_editor
    unless @current_user.is_admin? || @current_user.is_instructor?
      redirect_to root_path
    end
  end

end
