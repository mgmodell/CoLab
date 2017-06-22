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

  # Data transport class
  class Event_
    attr_accessor :name, :task_link, :task_name_post, :type, :status, :group_name
    attr_accessor :course_name, :start_time, :close_date
  end

  def demo_start
    @title = t 'titles.demonstration'
    if @current_user.nil?
      @current_user = User.new(first_name: 'John', last_name: 'Smith', timezone: 'Seoul')
    end

    e = Event_.new
    e.name = 'SuperStars'
    e.task_link = assessment_demo_complete_path
    e.task_name_post = '<br>' + "(#{t :project}: Research Paper)"
    e.type = t 'home.sapa'
    e.status = t :not_started
    e.group_name = 'SuperStars'
    e.course_name = 'Advanced Collaborative Research'
    e.start_time = 1.day.ago
    e.close_date = 1.day.from_now.end_of_day

    @events = [e]
    e = Event_.new
    e.name = 'What is collaboration?'
    e.task_link = bingo_demo_complete_path
    e.task_name_post = ''
    e.type = t 'home.terms_list'
    e.status = '50%'
    e.group_name = 'SuperStars'
    e.course_name = 'Advanced Collaborative Research'
    e.start_time = 1.week.ago
    e.close_date = 2.day.from_now.end_of_day
    @events << e
  end
end
