# frozen_string_literal: true

require 'forgery'
class BingoGame < ApplicationRecord
  include TimezonesSupportConcern

  belongs_to :course, inverse_of: :bingo_games
  has_many :candidate_lists, inverse_of: :bingo_game, dependent: :destroy
  has_many :bingo_boards, inverse_of: :bingo_game, dependent: :destroy
  belongs_to :project, inverse_of: :bingo_games, optional: true

  has_many :candidates, through: :candidate_lists
  has_many :users, through: :course
  has_many :groups, through: :project

  has_many :concepts, through: :candidates

  # validations
  validates :course, :topic, :end_date, :start_date, presence: true
  validates :group_discount, numericality:
    { only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100,
      allow_nil: true }
  validates :individual_count, numericality: { only_integer: true }
  validate :date_sanity
  validate :review_completed

  validate :group_components

  validate :dates_within_course
  before_create :anonymize
  # before_validation :init_dates
  before_save :reset_notification

  def status_for_user(user)
    candidate_list_for_user(user).status
  end

  def status
    completed = candidates.completed.count
    if completed > 0
      100 * candidates.reviewed.count / candidates.completed.count
    else
      0
    end
  end

  def playable?
    get_concepts.size > (size * size)
  end

  def practicable?
    playable? &&
      (candidates.acceptable.distinct(:concept_id).size >= 10)
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
    end_date - (1 + lead_time).days
  end

  def task_data(current_user:)
    # TODO: There's got to be a better way
    group = self.project.group_for_user(current_user) if project.present?
    helpers = Rails.application.routes.url_helpers
    link = if awaiting_review?
             helpers.review_bingo_candidates_path(self)
           else
             candidate_list = candidate_list_for_user(current_user)
             if is_open?
               helpers.edit_candidate_list_path(candidate_list)
             elsif reviewed
               helpers.candidate_list_path(candidate_list)
             end
          end

    log = course.get_consent_log(user: current_user)
    consent_link = log.present? ?
                     helpers.edit_consent_log_path(
                       consent_form_id: log.consent_form_id
                     ) : nil
    {
      id: id,
      type: :bingo_game,
      name: get_name(false),
      group_name: group.present? ? group.get_name(false) : nil,
      status: status,
      course_name: course.get_name(false),
      start_date: start_date,
      end_date: end_date,
      next_date: self.next_deadline,
      link: link,
      consent_link: consent_link,
      active: active
    }
  end

  # Let's create a true activity interface later
  # TODO this is really more of a student activity end date
  def get_link
    # helpers = Rails.application.routes.url_helpers
    # helpers.bingo_game_path self
    'bingo_game'
  end

  def type
    'Terms List'
  end

  def get_activity_begin
    term_list_date
  end

  def get_events(user:)
    helpers = Rails.application.routes.url_helpers
    events = []
    user_role = course.get_user_role(user)

    cl = nil
    edit_url = nil
    destroy_url = nil
    if user_role == 'instructor'
      edit_url = helpers.edit_bingo_game_path(self)
      destroy_url = helpers.bingo_game_path(self)
      cl = candidate_list_for_user(user)
    end

    if (active && user_role == 'enrolled_student') ||
       (user_role == 'instructor')
      events << {
        type: 'bingo_game',
        id: "bg_#{id}",
        title: topic,
        start: start_date,
        end: end_date,
        allDay: true,
        backgroundColor: '#9999CC',
        edit_url: edit_url,
        destroy_url: destroy_url,
        activities: [
          {
            type: 'terms_list_entry',
            start: start_date,
            end: term_list_date,
            actor: cl.nil? ? 'instructor' :
              (cl.is_group? ? 'group' : 'solo'),
            url: (is_open? && user_role) == 'enrolled_student' ?
              helpers.edit_candidate_list_path(cl) : nil
          },
          {
            type: 'terms_list_review',
            start: term_list_date + 1.day,
            end: end_date,
            actor: user_role == 'enrolled_student' && reviewed ?
              'solo' : 'instructor',
            url: is_open? ? nil :
              (user_role == 'instructor' ? helpers.review_bingo_candidates_path(self) :
                (reviewed ? helpers.candidate_list_path(cl) : nil))
          }
        ]
      }
    end
    events
  end

  def get_activity_on_date(date:, anon:)
    if date <= term_list_date
      "#{I18n.t(:terms_list)} (#{get_name(anon)})"
    else
      "#{I18n.t(:terms_review)} (#{get_name(anon)})"
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
    start_date <= cur_date && term_list_date >= cur_date
  end

  def required_terms_for_contributors(contributor_count)
    remaining_percent = (100.0 - group_discount) / 100
    discounted = (contributor_count * individual_count * remaining_percent).floor
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
    !reviewed && term_list_date <= DateTime.current && end_date >= DateTime.current
  end

  def self.inform_instructors
    count = 0
    BingoGame.includes(:course).where(instructor_notified: false).find_each do |bingo|
      next unless bingo.end_date < DateTime.current + (1 + bingo.lead_time).days

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
    cl = candidate_lists.find_by(user_id: user.id)
    if cl.nil?
      cl = CandidateList.new
      cl.user_id = user.id
      cl.bingo_game_id = id
      cl.contributor_count = 1
      cl.archived = false
      cl.is_group = false
      cl.group_requested = false
      cl.current_candidate_list = nil

      individual_count.times do
        cl.candidates << Candidate.new(term: '', definition: '', user: user)
      end
      cl.save unless id == -1 # This unless supports the demonstration only
      logger.debug cl.errors.full_messages unless cl.errors.empty?
    elsif  cl.archived
      # TODO: I think I can fix this
      cl = cl.current_candidate_list
    end
    cl
  end

  private

  def reset_notification
    if end_date_changed? && instructor_notified && term_list_date <= end_date
      self.instructor_notified = false
    end
  end

  def init_dates
    self.start_date ||= course.start_date
    self.end_date ||= course.end_date
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
