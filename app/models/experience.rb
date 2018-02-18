# frozen_string_literal: true

require 'forgery'
class Experience < ApplicationRecord
  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience

  # validations
  validates :name, :end_date, :start_date, presence: true
  validate :date_sanity
  before_validation :timezone_adjust
  before_create :anonymize
  validate :dates_within_course

  scope :active_at, ->(date) {
                      where(active: true)
                        .where('experiences.start_date <= ? AND experiences.end_date >= ?', date, date) }

  def get_user_reaction(user)
    reaction = reactions.includes(narrative: { scenario: :behavior }).where(user: user).take

    reaction = Reaction.create(user: user, experience: self, instructed: false) if reaction.nil?
    reaction
  end

  def get_type
    I18n.t(:experience)
  end

  def next_deadline
    end_date
  end

  def get_activity_on_date(date:, anon:)
    get_name(anon)
  end

  def type
    'Group work simulation'
  end

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  def status_for_user(user)
    get_user_reaction(user).status
  end

  def get_least_reviewed_narrative(include_ids = [])
    narrative_counts = if include_ids.empty?
                         reactions.group(:narrative_id).count
                       else
                         reactions
                           .where(narrative_id: include_ids)
                           .group(:narrative_id).count
                       end

    narrative = nil
    if narrative_counts.empty?
      if include_ids.empty?
        narrative = Narrative.includes(scenario: :behavior).all.sample
      else
        narrative_counts = Reaction.includes(:narrative)
                                   .where(narrative_id: include_ids)
                                   .group(:narrative_id).count
        if narrative_counts.count < include_ids.count
          possible = include_ids - narrative_counts.keys
          narrative = Narrative.includes(scenario: :behavior).find(possible.sample)
        else
          sorted =  narrative_counts.sort_by { |a| a[1] }
          narrative = Narrative.includes(scenario: :behavior).find ( sorted[0][0])
        end
        # narrative = Narrative.where( id: include_ids).take
      end
    elsif narrative_counts.count < Narrative.includes(scenario:
    :behavior).all.count

      scenario_counts = reactions.joins(:narrative).group(:scenario_id).count

      if scenario_counts.count < Scenario.all.count
        # Must account for completed counts - add: and not IN narrative_counts
        exp = include_ids - narrative_counts.keys
        world = exp - Reaction.group(:narrative_id).count.keys

        i = Narrative.includes(scenario: :behavior).joins(:reactions).where('scenario_id NOT IN (?)', scenario_counts.keys)
                     .where(reactions: { narrative_id: exp })
                     .group(:narrative_id).count
        if include_ids.empty?
          narrative = Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where('id NOT IN (?)', narrative_counts.keys).sample
        elsif world.count > 0
          narrative = Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: world).sample

        elsif exp.count > 0
          narrative = Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: world).sample
        else
          narrative = Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: include_ids).sample
        end
      end

      if narrative.nil?
        narrative = Narrative.includes(scenario: :behavior).where('id NOT IN (?)', narrative_counts.keys).sample
      end
    else
      narrative = Narrative.includes(scenario: :behavior).find(narrative_counts.sort_by { |a| a[1] }[0][0])
    end
    narrative
  end

  def is_open
    if start_date <= DateTime.current && end_date >= DateTime.current
      true
    else
      false
    end
  end

  def get_narrative_counts
    reactions.group(:narrative).count.to_a.sort! { |x, y| x[1] <=> y[1] }
  end

  def get_scenario_counts
    reactions.joins(narrative: :scenario).group(:scenario_id).count.to_a.sort! { |x, y| x[1] <=> y[1] }
  end

  def self.inform_instructors
    count = 0
    Experience.where('instructor_updated = false AND end_date < ?', DateTime.current).each do |experience|
      completion_hash = {}
      experience.course.enrolled_students.each do |student|
        reaction = experience.get_user_reaction student
        completion_hash[student.email] = { name: student.name(false), status: reaction.status }
      end

      experience.course.instructors.each do |instructor|
        AdministrativeMailer.summary_report(experience.name + ' (experience)',
                                            experience.course.pretty_name,
                                            instructor,
                                            completion_hash).deliver_later
        count += 1
      end
      experience.instructor_updated = true
      experience.save
      puts experience.errors.full_messages unless experience.errors.empty?
    end
    logger.debug "\n\t**#{count} Experience Reports sent to Instructors**"
  end

  private

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
        errors.add(:start_date, "The experience cannot begin before the course has begun (#{course.start_date})")
      end
      if end_date.change(sec: 0) > course.end_date.change(sec: 0)
        msg = 'The experience cannot continue after the course has ended '
        msg += "(#{end_date} > #{course.end_date})"
        errors.add(:end_date, msg)
      end
    end
    errors
  end

  def anonymize
    self.anon_name = Forgery::Name.company_name.to_s
  end
end
