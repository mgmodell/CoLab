# frozen_string_literal: true
class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:demo_start]

  def index
    @current_user = current_user
    # The first thing we want to do is make sure they've had an opportunity to
    # complete any waiting consent forms
    waiting_consent_logs = @current_user.waiting_consent_logs
    if waiting_consent_logs.count > 0
      redirect_to(controller: 'consent_logs',
                  action: 'edit',
                  consent_form_id: waiting_consent_logs[0].consent_form_id)
    elsif @current_user.rosters.awaiting.count > 0
      @waiting_rosters = current_user.rosters.awaiting
      render :rsvp
    elsif !current_user.welcomed?
      redirect_to edit_user_registration_path(@current_user)
    end
    @first_name = current_user.first_name
    @waiting_student_tasks = current_user.waiting_student_tasks
    @waiting_instructor_tasks = current_user.waiting_instructor_tasks
    @current_location = 'home'
  end

  def demo_start
    @title = "Demonstration"
  end
end
