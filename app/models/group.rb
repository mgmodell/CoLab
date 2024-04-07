# frozen_string_literal: true

require 'faker'
class Group < ApplicationRecord
  around_update :update_history
  after_initialize :store_load_state

  belongs_to :project, inverse_of: :groups
  has_and_belongs_to_many :users, inverse_of: :groups,
                                  after_add: :set_dirty, after_remove: :set_dirty
  has_many :group_revisions, inverse_of: :group, dependent: :destroy
  has_many :candidate_lists, inverse_of: :group, dependent: :nullify

  has_many :installments, inverse_of: :group, dependent: :destroy

  # For Diversity calculation
  has_many :home_states, through: :users
  has_many :home_countries, through: :home_states
  has_many :cip_codes, through: :users
  has_many :genders, through: :users
  has_many :primary_languages, through: :users
  has_many :submissions, inverse_of: :group, dependent: :nullify

  validates :name, presence: true
  validate :validate_activation_status

  before_create :anonymize

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  def calc_diversity_score
    self.diversity_score = Group.calc_diversity_score_for_group(
      users: users.includes(:gender, :primary_language,
                            :cip_code, reactions: :narrative,
                                       home_state: [:home_country])
    )
  end

  def self.calc_diversity_score_for_proposed_group(emails:)
    users = User.joins(:emails).where(emails: { email: emails.split(/\s*,\s*/) })
                .includes(:gender, :primary_language,
                          :cip_code, reactions: :narrative,
                                     home_state: [:home_country])

    Group.calc_diversity_score_for_group users:
  end

  def self.calc_diversity_score_for_group(users:)
    ds = 0
    if users.count > 1
      state_hash = Hash.new(0)
      country_hash = Hash.new(0)
      cip_hash = Hash.new(0)
      gender_hash = Hash.new(0)
      primary_lang_hash = Hash.new(0)
      country_hash = Hash.new(0)
      scenario_hash = Hash.new(0)
      impairment_hash = Hash.new(0)

      users.uniq.each do |user|
        if user.home_state.present?
          state_hash[user.home_state] += 1 unless
            true == user.home_state_no_response
          country_hash[user.home_state.home_country] += 1 unless
            true == user.home_state_home_country.no_response
        end
        cip_hash[user.cip_code] += 1 unless
            user.cip_code.nil? || user.cip_code_gov_code.zero?
        primary_lang_hash[user.primary_language] += 1 unless
            user.primary_language.nil? || '__' == user.primary_language_code
        gender_hash[user.gender] += 1 unless
            user.gender.nil? || '__' == user.gender_code
        user.reactions.each do |reaction|
          scenario_hash[reaction.narrative.member] += 1
        end
        impairments = ''
        impairments += user.impairment_visual ? 'v' : ''
        impairments += user.impairment_auditory ? 'a' : ''
        impairments += user.impairment_motor ? 'm' : ''
        impairments += user.impairment_cognitive ? 'c' : ''
        impairments += user.impairment_other ? 'o' : ''
        # if there are no impairments, set it to 'u'
        impairments += impairments.blank? ? 'u' : ''
        impairment_hash[impairments] = true
      end

      now = Date.current
      values = [].extend(DescriptiveStatistics)
      users.each do |user|
        values << now.year - user.date_of_birth.year if user.date_of_birth?
      end
      age_sd = values.empty? ? 0 : values.standard_deviation

      values.clear
      users.each do |user|
        values << now.year - user.started_school.year if user.started_school?
      end
      uni_years_sd = values.empty? ? 0 : values.standard_deviation

      ds = state_hash.keys.count +
           country_hash.keys.count +
           scenario_hash.keys.count +
           (2 * (gender_hash.keys.count + cip_hash.keys.count + primary_lang_hash.keys.count)) +
           (age_sd + uni_years_sd).round +
           (impairment_hash.keys.count > 1 ? impairment_hash.keys.count : 0)
    end
    ds
  end

  private

  def store_load_state
    @initial_member_state = ''
    user_ids.sort.each do |user_id|
      @initial_member_state += "#{user_id} "
    end
  end

  # Maintain a history of what has changed
  def update_history
    member_string = ''
    user_ids.sort.each do |user_id|
      member_string += "#{user_id} "
    end
    if changed? || @initial_member_state != member_string
      gr = group_revisions.new(name: name_was, group: self, members: member_string)
      calc_diversity_score if @initial_member_state != gr.members
    end

    # i_changed = (changed? || @initial_member_state != gr.members)

    yield # Do that save thing

    # gr.save if persisted? && i_changed
  end

  def validate_activation_status
    if persisted? && project_id_was != project_id
      errors.add(:project,
                 'It is not possible to move a group from one project to another.')
    end
    return unless changed? || @dirty

    project.active = false
    project.save!
  end

  def set_dirty(_user)
    @dirty = true
  end

  def anonymize
    self.anon_name = "#{rand < rand ? Faker::Nation.language : Faker::Nation.nationality} #{Faker::Company.name}s"
  end
end
