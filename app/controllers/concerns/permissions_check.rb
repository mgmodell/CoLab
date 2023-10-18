# frozen_string_literal: true

module PermissionsCheck
  extend ActiveSupport::Concern

  def check_viewer
    redirect_to root_path unless current_user.is_admin? ||
                                 current_user.is_instructor? ||
                                 current_user.is_researcher?
  end

  def check_admin
    redirect_to root_path unless current_user.is_admin?
  end

  def check_editor
    redirect_to root_path unless current_user.is_admin? || current_user.is_instructor?
  end
end
