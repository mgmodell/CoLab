# frozen_string_literal: true
class BingoGame < ActiveRecord::Base
  belongs_to :course, inverse_of: :bingo_games
  has_many :candidate_lists, inverse_of: :bingo_game, dependent: :destroy
  belongs_to :project, inverse_of: :bingo_games

  has_many :candidates, through: :candidate_lists

  has_many :concepts, through: :candidates

  # validations
  validates :topic, :end_date, :start_date, presence: true
  validates :group_discount, numericality:
    { only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100,
      allow_nil: true }
  validates :individual_count, numericality: { only_integer: true }
  validate :date_sanity
  validate :review_completed

  validate :group_components

  before_validation :timezone_adjust
  validate :dates_within_course

  def status
    completed = candidates.completed.count
    if completed > 0
      return 100 * candidates.reviewed.count / candidates.completed.count
    else
      return 0
    end
  end

  def name
    topic
  end

  def is_open?
    start_date <= DateTime.current && end_date >= (DateTime.current + lead_time.days)
  end

  def required_terms_for_group(group)
    remaining_percent = (100.0 - group_discount) / 100
    discounted = (group.users.count * individual_count * remaining_percent).floor
  end

  def awaiting_review?
    !reviewed && end_date <= (DateTime.current + lead_time.days) && end_date >= DateTime.current
  end

  def self.inform_instructors
    count = 0
    BingoGame.where(instructor_notified: false).each do |bingo|
      next unless bingo.end_date < DateTime.current + bingo.lead_time.days
      completion_hash = {}
      bingo.course.enrolled_students.each do |student|
        candidate_list = bingo.candidate_list_for_user(student)
        completion_hash[student.email] = { name: student.name,
                                           status: candidate_list.percent_complete.to_s + '%' }
      end

      bingo.course.instructors.each do |instructor|
        AdministrativeMailer.summary_report(bingo.name + ' (terms list)',
                                            bingo.course.prettyName,
                                            instructor,
                                            completion_hash).deliver_later
        count += 1
      end
      bingo.instructor_notified = true
      bingo.save
    end
    logger.debug "\n\t**#{count} Candidate Terms List reports sent to Instructors**"
  end

  def candidate_list_for_user(user)
    cl = candidate_lists.where(user_id: user.id).take
    if cl.nil?
      cl = CandidateList.new
      cl.user_id = user.id
      cl.bingo_game_id = id
      cl.is_group = false
      cl.group_requested = false

      individual_count.times do
        cl.candidates << Candidate.new(term: '', definition: '', user: user)
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
        errors.add(:start_date, "The bingo game cannot begin before the course has begun (#{course.start_date.strftime '%F'})")
      end
      if end_date > course.end_date
        errors.add(:end_date, "The bingo game cannot occur after the course has ended (#{course.end_date.strftime '%F'})")
      end
    end
    errors
  end

  def review_completed
    if reviewed && candidates.reviewed.count < candidates.completed.count
      errors.add(:reviewed, "You must review all candidates to mark the review 'completed'")
    end
  end

  # We must validate group components {project and discount}
  def group_components
    if group_option
      if project.nil?
        errors.add(:project_id,
                   'The group option requires that a project be selected')
      end
      if group_discount.nil?
        errors.add(:group_discount,
                   'The group option requires that a group discount be entered')
      end
    end
  end
end
