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

  def calc_diversity_score
    self.diversity_score = Group.calc_diversity_score_for_group(
              users: self.users.includes( :gender, :primary_language,
                  :cip_code,
                  home_state: [:home_country ] ,
                  reactions: [narrative: [:scenario] ] ) )

  end

  def self.calc_diversity_score_for_proposed_group emails:
    users = User.joins( :emails ).where( emails: emails.split(/\s*,\s*/) ).
      includes( :gender, :primary_language,
                  :cip_code,
                  home_state: [:home_country ] ,
                  reactions: [narrative: [:scenario] ] )

    Group.calc_diversity_score_for_group uers: users
  end

  def self.calc_diversity_score_for_group users:
    state_hash = Hash.new( 0 )
    country_hash = Hash.new( 0 )
    cip_hash = Hash.new( 0 )
    gender_hash = Hash.new( 0 )
    primary_lang_hash = Hash.new( 0 )
    country_hash = Hash.new( 0 )
    scenario_hash = Hash.new( 0 )
    
    users.each do |user|
      if user.home_state.present?
        state_hash[ user.home_state ] += 1 unless
          user.home_state.code == '__'
        country_hash[ user.home_state.home_country ] += 1 unless
          user.home_state.home_country.code == '__'
      end
      cip_hash[ user.cip_code ] += 1 unless
          user.cip_code.nil? || user.cip_code.gov_code == 0
      primary_lang_hash[ user.primary_language ] += 1 unless
          user.primary_language.nil? || user.primary_language.code == '__'
      gender_hash[ user.gender ] += 1 unless
          user.gender.nil? || user.gender.name_en == "I'd prefer not to answer"
      user.reactions.each do |reaction|
        scenario_hash[ reaction.narrative.scenario ] += 1
      end
    end

    now = Date.current
    values = [].extend(DescriptiveStatistics)
    users.each do |user|
      values << now.year - user.date_of_birth.year unless user.date_of_birth.nil?
    end
    age_sd = values.empty? ? 0 : values.standard_deviation

    values.clear
    users.each do |user|
      values << now.year - user.started_school.year unless user.started_school.nil?
    end
    uni_years_sd = values.empty? ? 0 : values.standard_deviation

    return state_hash.keys.count + primary_lang_hash.keys.count +
              country_hash.keys.count + scenario_hash.keys.count +
              (2 * (gender_hash.keys.count + cip_hash.keys.count)) +
              (age_sd + uni_years_sd).round
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

    calc_diversity_score if i_changed
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
