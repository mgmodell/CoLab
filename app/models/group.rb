# frozen_string_literal: true
require 'forgery'
class Group < ActiveRecord::Base
  around_update :track_history
  after_initialize :store_load_state

  belongs_to :project, inverse_of: :groups
  has_and_belongs_to_many :users, inverse_of: :groups,
                                  after_add: :set_dirty, after_remove: :set_dirty
  has_many :group_revisions, inverse_of: :group, dependent: :destroy
  has_many :candidate_lists, inverse_of: :group

  has_many :installments, inverse_of: :group, dependent: :destroy

  # For Diversity calculation
  has_many :home_states, through: :users
  has_many :home_countries, through: :home_states
  has_many :cip_codes, through: :users
  has_many :genders, through: :users
  has_many :primary_languages, through: :users
  has_many :reactions, through: :users
  has_many :scenarios, through: :reactions

  validates :name, :project_id, presence: true
  validate :validate_activation_status

  before_create :anonymize

  def get_name(anonymous)
    anonymous ? anon_name : name
  end

  def has_user(user)
    users.where('users.id = ?', user.id).any?
  end

  def users_changed?
    users.select { |u| u.new_record? || u.marked_for_destruction? }.any?
  end

  def diversity_score_update
    state_count = home_states.where.not( code: '??' ) .uniq.count
    country_count = home_countries.where.not( code: '??' ).uniq.count
    cip_count = cip_codes.where.not( gov_code: 0 ).uniq.count
    gender_count = genders.where.not( name_en: "I'd prefer not to answer" ).uniq.count
    primary_lang_count = primary_languages.where.not( code: '??' ).uniq.count
    scenario_count = scenarios.uniq.count

    now = Date.current
    values = [].extend(DescriptiveStatistics)
    self.users.each do |user|
      values << now.year - user.date_of_birth.year
    end
    age_sd = values.standard_deviation

    values = [].clear
    self.users.each do |user|
      values << now.year - user.started_school.year
    end
    uni_years_sd = values.standard_deviation

    self.diversity_score = state_count + country_count + 
              primary_lang_count + scenario_count + 
              (2 * (gender_count + cip_count) ) +
              (age_sd + uni_years_sd ).round

  end

  private

  def store_load_state
    @initial_member_state = ''
    user_ids.each do |user_id|
      @initial_member_state += user_id.to_s + ' '
    end
  end

  # Maintain a history of what has changed
  def track_history
    gr = GroupRevision.new(group: self, members: '')
    gr.name = name_was
    user_ids.each do |user_id|
      gr.members += user_id.to_s + ' '
    end
    i_changed = (changed? || @initial_member_state != gr.members)

    self.diversity_score_update if i_changed
    yield # Do that save thing

    gr.save if persisted? && i_changed
  end

  def validate_activation_status
    if persisted? && project_id_was != project_id
      errors.add(:project,
                 'It is not possible to move a group from one project to another.')
    end
    if changed? || @dirty
      project.active = false
      project.save
    end
  end

  def set_dirty(_user)
    @dirty = true
  end

  def anonymize
    anon_name = "#{rand < rand ? Forgery::Personal.language : Forgery::Name.location} #{Forgery::Name.company_name}s"
  end
end
