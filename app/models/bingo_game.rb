# frozen_string_literal: true
class BingoGame < ActiveRecord::Base
  belongs_to :course, inverse_of: :bingo_games
  has_many :candidate_lists, inverse_of: :bingo_game, dependent: :destroy
  belongs_to :project, inverse_of: :bingo_games

  # validations
  validates :topic, :end_date, :start_date, :project_id, presence: true
  validate :date_sanity
  before_validation :timezone_adjust
  validate :dates_within_course

  def name
    topic
  end

  def is_open
    if start_date <= DateTime.current && end_date >= (DateTime.current - lead_time.day)
      true
    else
      false
    end
  end

  def candidate_list_for_user(user)
    cl = candidate_lists.where(user_id: user.id).take
    if cl.nil?
      cl = CandidateList.new
      cl.user_id = user.id
      cl.bingo_game_id = id
      cl.group_id = project.group_for_user(user)
      cl.is_group = false
      cl.group_requested = false

      individual_count.times do
        cl.candidates << Candidate.new(name: '', definition: '')
      end
      cl.save
    elsif  cl.is_group
      cl = candidate_lists.where(group_id: project.group_for_user(user).id).take
    end
    cl
  end

  # validation methods
  def date_sanity
    unless start_date.nil? || end_date.nil?
      if start_date > end_date
        errors.add(:start_date, 'The start date must come before the end date')
      end
      errors
    end
  end

  def timezone_adjust
    course_tz = ActiveSupport::TimeZone.new(course.timezone)
    user_tz = Time.zone

    unless start_date == course.start_date && new_record?
      # TZ corrections
      new_date = start_date - user_tz.utc_offset + course_tz.utc_offset
      self.start_date = new_date.getlocal(course_tz.utc_offset).beginning_of_day if start_date_changed?
      new_date = end_date - user_tz.utc_offset + course_tz.utc_offset
      self.end_date = new_date.getlocal(course_tz.utc_offset).end_of_day if end_date_changed?
    end
  end

  def dates_within_course
    unless start_date.nil? || end_date.nil?
      if start_date < course.start_date
        errors.add(:start_date, 'The bingo game cannot begin before the course has begun')
      end
      if end_date > course.end_date
        errors.add(:end_date, 'The bingo game cannot continue after the course has ended')
      end
    end
    errors
  end
end
