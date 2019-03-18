# frozen_string_literal: true

require 'forgery'
class BingoGame < ApplicationRecord
  belongs_to :course, inverse_of: :bingo_games
  has_many :candidate_lists, inverse_of: :bingo_game, dependent: :destroy
  has_many :bingo_boards, inverse_of: :bingo_game, dependent: :destroy
  belongs_to :project, inverse_of: :bingo_games, optional: true

  has_many :candidates, through: :candidate_lists
  has_many :users, through: :course
  has_many :groups, through: :project

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
  before_create :anonymize
  before_save :reset_notification

  def status_for_user(user)
    candidate_list_for_user(user).status
  end

  def status
    completed = candidates.completed.count
    if completed > 0
      return 100 * candidates.reviewed.count / candidates.completed.count
    else
      return 0
    end
  end

  def playable?
    get_concepts.size > ( size * size )
  end

  def practicable?
    playable? &&
      (candidates.acceptable.distinct( :concept_id ).size >= 10 )

  end

  def get_concepts
    concepts.to_a.uniq
  end

  def get_topic(anonymous)
    anonymous ? anon_topic : topic
  end

  def get_name(anonymous)
    anonymous ? anon_topic : topic
  end

  def get_type
    I18n.t(:terms_list)
  end

  def term_list_date
    end_date - lead_time.days
  end

  def get_activity_on_date(date:, anon:)
    if date <= term_list_date
      "#{I18n.t(:terms_list)} (#{get_name(anon)})"
    else
      "#{I18n.t(:terms_revieew)} (#{get_name(anon)})"
    end
  end

  def next_deadline
    if is_open?
      term_list_date
    else
      end_date
    end
  end

  def is_open?
    cur_date = DateTime.current
    start_date <= cur_date && end_date >= (cur_date + lead_time.days)
  end

  def required_terms_for_group(group)
    remaining_percent = (100.0 - group_discount) / 100
    group_user_count = group.nil? ? 1 : group.users.count
    discounted = (group_user_count * individual_count * remaining_percent).floor
  end

  def get_current_lists_hash
    candidate_lists = {}
    course.rosters.enrolled_student.each do |roster|
      student = roster.user
      candidate_list = candidate_list_for_user(student)
      if candidate_lists[candidate_list].nil?
        candidate_lists[candidate_list] = [student]
      else
        candidate_lists[candidate_list] << student
      end
    end
    candidate_lists
  end

  def awaiting_review?
    !reviewed && end_date <= (DateTime.current + lead_time.days) && end_date >= DateTime.current
  end

  def self.inform_instructors
    count = 0
    BingoGame.includes(:course).where(instructor_notified: false).each do |bingo|
      next unless bingo.end_date < DateTime.current + bingo.lead_time.days

      completion_hash = {}
      bingo.course.enrolled_students.each do |student|
        candidate_list = bingo.candidate_list_for_user(student)
        completion_hash[student.email] = { name: student.name(false),
                                           status: candidate_list.percent_completed.to_s + '%' }
      end

      bingo.course.instructors.each do |instructor|
        AdministrativeMailer.summary_report(bingo.get_name(false) + ' (terms list)',
                                            bingo.course.pretty_name,
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
      cl.save unless id == -1 # This unless supports the demonstration only
    elsif  cl.is_group
      # TODO: I think I can fix this
      cl = candidate_lists.where(group_id: project.group_for_user(user).id).take
    end
    cl
  end

  private

  def reset_notification
    if end_date_changed? && instructor_notified && ((DateTime.current + lead_time.days) <= end_date)
      self.instructor_notified = false
    end
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

    if start_date.nil? || start_date.change(hour: 0) == course.start_date.change(hour: 0)
      self.start_date = course.start_date
    elsif start_date_changed?
      proc_date = course_tz.local(start_date.year, start_date.month, start_date.day)
      self.start_date = proc_date.beginning_of_day
    end

    if end_date.nil? || end_date.change(hour: 0) == course.end_date.change(hour: 0)
      self.end_date = course.end_date
    elsif end_date_changed?
      proc_date = course_tz.local(end_date.year, end_date.month, end_date.day)
      self.end_date = proc_date.end_of_day.change(sec: 0)
    end
  end

  def dates_within_course
    unless start_date.nil? || end_date.nil?
      if start_date < course.start_date
        msg = I18n.t('bingo_games.start_date_err',
                     start_date: start_date,
                     course_start_date: course.start_date)
        errors.add(:start_date, msg)
      end
      if end_date.change(sec: 0) > course.end_date.change(sec: 0)
        msg = I18n.t('bingo_games.end_date_err',
                     end_date: end_date,
                     course_end_date: course.end_date)
        errors.add(:end_date, msg)
      end
    end
    errors
  end

  def review_completed
    if reviewed && candidates.reviewed.count < candidates.completed.count
      errors.add(:reviewed, I18n.t('bingo_games.reviewed_err'))
    end
  end

  # We must validate group components {project and discount}
  def group_components
    if group_option
      if project.nil?
        errors.add(:project_id, I18n.t('bingo_games.group_requires_project'))
      end
      if group_discount.nil?
        errors.add(:group_discount, I18n.t('bingo_games.group_requires_discount'))
      end
    end
  end

  def anonymize
    trans = ['basics for a', 'for an expert', 'in the news with a novice', 'and Food Pyramids - for the']
    self.anon_topic = "#{Forgery::Name.company_name} #{trans.sample} #{Forgery::Name.job_title}"
  end
end
