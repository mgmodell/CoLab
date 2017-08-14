# frozen_string_literal: true
require 'forgery'
class Experience < ActiveRecord::Base
  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience

  # validations
  validates :name, :end_date, :start_date, presence: true
  validate :date_sanity
  before_validation :timezone_adjust
  before_create :anonymize
  validate :dates_within_course

  scope :still_open, -> {
    where('experiences.start_date <= ? AND experiences.end_date >= ?',
          DateTime.current, DateTime.current)
  }

  def get_user_reaction(user)
    reaction = reactions.where(user: user).take

    reaction = Reaction.create(user: user, experience: self, instructed: false) if reaction.nil?
    reaction
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
        narrative = Narrative.take
      else
        narrative_counts = Reaction.includes(:narrative)
                                   .where(narrative_id: include_ids)
                                   .group(:narrative_id).count
        if narrative_counts.count < include_ids.count
          possible = include_ids - narrative_counts.keys
          narrative = Narrative.find(possible.sample)
        else
          sorted =  narrative_counts.sort { |x, y| x[1] <=> y[1] }
          narrative = Narrative.find ( sorted[0][0])
        end
        # narrative = Narrative.where( id: include_ids).take
      end
    elsif narrative_counts.count < Narrative.all.count

      scenario_counts = reactions.joins(:narrative).group(:scenario_id).count

      if scenario_counts.count < Scenario.all.count
        # Must account for completed counts - add: and not IN narrative_counts
        exp = include_ids - narrative_counts.keys
        world = exp - Reaction.group(:narrative_id).count.keys

        i = Narrative.joins(:reactions).where('scenario_id NOT IN (?)', scenario_counts.keys)
                     .where(reactions: { narrative_id: exp })
                     .group(:narrative_id).count
        if include_ids.empty?
          narrative = Narrative.where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where('id NOT IN (?)', narrative_counts.keys).take
        elsif world.count > 0
          narrative = Narrative.where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: world).take

        elsif exp.count > 0
          narrative = Narrative.where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: world).take
        else
          narrative = Narrative.where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: include_ids).take
        end
      end

      if narrative.nil?
        narrative = Narrative.where('id NOT IN (?)', narrative_counts.keys).take
      end
    else
      narrative = Narrative.find(narrative_counts.sort { |x, y| x[1] <=> y[1] }[0][0])
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
        errors.add(:start_date, "The experience cannot begin before the course has begun (#{course.start_date})")
      end
      if end_date > course.end_date
        errors.add(:end_date, "The experience cannot continue after the course has ended (#{course.end_date})")
      end
    end
    errors
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
    end
    logger.debug "\n\t**#{count} Experience Reports sent to Instructors**"
  end

  private

  def anonymize
    anon_name = Forgery::Name.company_name.to_s
  end
end
