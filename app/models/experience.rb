# frozen_string_literal: true

require 'faker'
class Experience < ApplicationRecord
  include DateSanitySupportConcern
  include TimezonesSupportConcern

  belongs_to :course, inverse_of: :experiences
  has_many :reactions, inverse_of: :experience, dependent: :destroy

  # validations
  validates :name, :end_date, :start_date, presence: true
  before_create :anonymize
  before_save :reset_notification, :end_date_optimization

  # before_validation :init_dates # From DateSanitySupportConcern

  scope :active_at, lambda { |date|
                      where(active: true)
                        .where('experiences.start_date <= ? AND experiences.end_date >= ?', date, date)
                    }

  def get_user_reaction(user)
    reaction = reactions.includes(narrative: { scenario: :behavior }).find_by(user:)

    reaction = Reaction.create(user:, experience: self, instructed: false) if reaction.nil?
    reaction
  end

  def get_link
    'experience'
  end

  def get_type
    I18n.t(:experience)
  end

  def next_deadline
    end_date - (1 + lead_time).days
  end

  def get_activity_on_date(date:, anon:)
    get_name(anon)
  end

  # TODO: We should get rid of this with new calendaring
  # TODO this is really more of a student activity end date
  def get_activity_begin
    student_end_date
  end

  def get_events(user:)
    helpers = Rails.application.routes.url_helpers
    events = []
    user_role = course.get_user_role(user)
    edit_url = nil
    destroy_url = nil
    sim_url = helpers.next_experience_path(experience_id: id)

    if user_role == 'instructor'
      edit_url = helpers.edit_experience_path(self)
      destroy_url = helpers.experience_path(self)
      sim_url = nil
    end

    if (active && user_role == 'enrolled_student') ||
       (user_role == 'instructor')
      events << {
        type: 'experience',
        id: "exp_in_#{id}",
        title: name,
        start: start_date,
        end: end_date,
        allDay: true,
        backgroundColor: '#99CC99',
        edit_url:,
        destroy_url:,
        activities: [
          {
            type: 'sim_exp',
            start: start_date,
            end: student_end_date,
            actor: 'solo',
            url: sim_url
          },
          {
            type: 'sim_exp_review',
            start: student_end_date + 1.day,
            end: end_date,
            actor: 'instructor',
            url: nil
          }
        ]
      }
    end
    events
  end

  def type
    'Group Experience'
  end

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  def status_for_user(user)
    get_user_reaction(user).status
  end

  def task_data(current_user:)
    helpers = Rails.application.routes.url_helpers
    link = "experience/#{id}"

    log = course.get_consent_log(user: current_user)
    consent_link = if log.present?
                     helpers.edit_consent_log_path(
                       consent_form_id: log.consent_form_id
                     )
                   end

    {
      id:,
      type: :experience,
      name: get_name(false),
      group_name: 'N/A',
      status: status_for_user(current_user),
      course_name: course.get_name(false),
      start_date:,
      end_date:,
      next_date: next_deadline,
      link:,
      consent_link:,
      active:
    }
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
          narrative = Narrative.includes(scenario: :behavior).find(sorted[0][0])
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

        i = Narrative.includes(scenario: :behavior).joins(:reactions).where('scenario_id NOT IN (?)',
                                                                            scenario_counts.keys)
                     .where(reactions: { narrative_id: exp })
                     .group(:narrative_id).count
        narrative = if include_ids.empty?
                      Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where('id NOT IN (?)', narrative_counts.keys).sample
                    elsif world.count.positive?
                      Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: world).sample

                    elsif exp.count.positive?
                      Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: world).sample
                    else
                      Narrative.includes(scenario: :behavior).where('scenario_id NOT IN (?)', scenario_counts.keys)
                               .where(id: include_ids).sample
                    end
      end

      if narrative.nil?
        narrative = Narrative.includes(scenario: :behavior).where('id NOT IN (?)', narrative_counts.keys).sample
      end
    else
      narrative = Narrative.includes(scenario: :behavior).find(narrative_counts.min_by { |a| a[1] }[0])
    end
    narrative
  end

  def is_open?
    cur_date = DateTime.current
    start_date <= cur_date && student_end_date >= cur_date
  end

  def get_narrative_counts
    reactions.group(:narrative).count.to_a.sort! { |x, y| x[1] <=> y[1] }
  end

  def get_scenario_counts
    reactions.joins(narrative: :scenario).group(:scenario_id).count.to_a.sort! { |x, y| x[1] <=> y[1] }
  end

  def self.inform_instructors
    count = 0
    cur_date = DateTime.current
    Experience.where('instructor_updated = false AND student_end_date < ?', cur_date).find_each do |experience|
      completion_hash = {}
      experience.course.enrolled_students.each do |student|
        reaction = experience.get_user_reaction student
        completion_hash[student.email] = { name: student.name(false), status: reaction.status }
      end

      experience.course.instructors.each do |instructor|
        AdministrativeMailer.summary_report("#{experience.name} (experience)",
                                            experience.course.pretty_name,
                                            instructor,
                                            completion_hash).deliver_later
        count += 1
      end
      experience.instructor_updated = true
      experience.save
      logger.debug experience.errors.full_messages unless experience.errors.empty?
    end
    logger.debug "\n\t**#{count} Experience Reports sent to Instructors**"
  end

  private

  def reset_notification
    self.instructor_updated = false if end_date_changed? && instructor_updated && DateTime.current <= end_date
  end

  def end_date_optimization
    return unless student_end_date.nil? || end_date_changed? || lead_time_changed?

    self.student_end_date = end_date - (1 + lead_time).days
  end

  def anonymize
    self.anon_name = "#{Faker::Company.industry} #{Faker::Company.suffix}"
  end
end
