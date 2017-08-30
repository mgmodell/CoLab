# frozen_string_literal: true
require 'forgery'

class User < ActiveRecord::Base
  has_many :emails, inverse_of: :user, dependent: :destroy

  devise :multi_email_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :multi_email_validatable, :multi_email_confirmable,
         :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_and_belongs_to_many :groups
  has_many :consent_logs, inverse_of: :user, dependent: :destroy
  has_many :candidate_lists, inverse_of: :user, dependent: :destroy
  has_many :concepts, inverse_of: :user, dependent: :destroy
  has_many :projects, through: :groups
  has_many :candidates, inverse_of: :user
  belongs_to :gender, inverse_of: :users
  belongs_to :theme, inverse_of: :users
  has_many :home_countries, through: :home_state
  belongs_to :home_state, inverse_of: :users
  belongs_to :cip_code, inverse_of: :users

  belongs_to :language, inverse_of: :users
  belongs_to :primary_language, inverse_of: :home_users, class_name: 'Language'

  belongs_to :school
  has_many :installments, inverse_of: :user, dependent: :destroy
  has_many :rosters, inverse_of: :user, dependent: :destroy
  has_many :courses, through: :projects

  has_many :reactions, inverse_of: :user, dependent: :destroy
  has_many :experiences, through: :reactions
  has_many :narratives, through: :experiences

  validates :timezone, :theme, presence: true

  has_many :assessments, through: :projects

  before_create :anonymize

  # Give us a standard form of the name
  def name(anonymous)
    if anonymous
      name = "#{anon_last_name}, #{anon_first_name}"
    else
      if last_name.nil? && first_name.nil?
        name = email
      else
        name = (!last_name.nil? ? last_name : '[No Last Name Given]') + ', '
        name += (!first_name.nil? ? first_name : '[No First Name Given]')
      end
    end
  end

  def informal_name(anonymous)
    if anonymous
      name = "#{anon_first_name} #{anon_last_name}"
    else
      if last_name.nil? && first_name.nil?
        name = email
      else
        name = (!first_name.nil? ? first_name : '[No First Name Given]') + ' '
        name += (!last_name.nil? ? last_name : '[No Last Name Given]')
      end
    end
  end

  def language_code
    language.nil? ? nil : language.code
  end

  def anonymize?
    researcher
  end

  def waiting_consent_logs
    # Find those consent forms to which the user has not yet responded
    all_consent_forms = ConsentForm.all.to_a

    # We only want to do this for currently active consent forms
    consent_forms = all_consent_forms.delete_if { |cf| !cf.is_active? }

    # Have we completed it already?
    consent_logs.where(presented: true).each do |consent_log|
      consent_forms.delete(consent_log.consent_form)
    end

    # Is it from a project that we're not in?
    projects_array = projects.to_a
    consent_forms.each do |consent_form|
      consent_form.projects.each do |cf_project|
        if !consent_form.global? && !projects_array.include?(cf_project)
          consent_forms.delete(consent_form)
          break
        end
      end
    end

    # Create consent logs for waiting consent forms
    waiting_consent_logs = []
    consent_forms.each do |w_consent_form|
      consent_log = ConsentLog.new(user: self, consent_form: w_consent_form)
      waiting_consent_logs << consent_log
    end
    waiting_consent_logs
  end

  def is_admin?
    admin
  end

  def is_instructor?
    if admin || rosters.instructorships.count > 0
      true
    else
      false
    end
  end

  def is_researcher?
    researcher
  end

  def waiting_instructor_tasks
    waiting_tasks = []

    BingoGame.joins( course: {rosters: :role} )
              .where( 'rosters.user_id': self.id, 'roles.code': 'inst' )
              .find_each do |game|
      waiting_tasks << game if game.awaiting_review?
    end

    waiting_tasks.sort_by(&:end_date)
  end

  def activity_history
    activities = []
    # Add in the candidate lists
    BingoGame.joins( course: {rosters: :role} )
                  .where( 'rosters.user_id': self.id)
                  .where( 'roles.code = ? OR roles.code = ?', 'enr', 'invt' )
                  .find_each do |bingo_game|

        activities << bingo_game
    end
    # Add in the reactions
    experiences.each do |experience|
      activities << experience
    end
    # Add in projects
    projects.each do |project|
      activities << project
    end

    activities.sort_by(&:end_date)
  end

  def waiting_student_tasks
    waiting_tasks = assessments.still_open.to_a

    # Check available tasks for students
    available_rosters = rosters.enrolled

    # Add the experiences
    cur_date = DateTime.current

    waiting_tasks.concat Experience.joins( course: {rosters: :role} )
              .where( 'rosters.user_id': self.id, 'experiences.active': true )
              .where( 'roles.code = ? OR roles.code = ?', 'enr', 'invt' )
              .where('experiences.end_date >= ? AND experiences.start_date <= ?', cur_date, cur_date )
              .to_a

    # Add the bingo games
    waiting_games = BingoGame.joins( course: {rosters: :role} )
              .where( 'rosters.user_id': self.id, 'bingo_games.active': true, 'bingo_games.reviewed': false )
              .where( 'roles.code = ? OR roles.code = ?', 'enr', 'invt' )
              .where('experiences.end_date >= ? AND experiences.start_date <= ?', cur_date, cur_date )
              .to_a
    waiting_games.delete_if { |game| !game.is_open? }
    waiting_tasks.concat waiting_games

    waiting_tasks.sort_by(&:end_date)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.joins(:emails).where(emails: { email: data['email'] }).first

    unless user
      user = User.create(
        email: data['email'],
        password: Devise.friendly_token[0, 20],
        timezone: 'UTC'
      )
    end
    user.confirm
    user
  end

  private

  def anonymize
    anon_first_name = Forgery::Name.first_name
    anon_last_name = Forgery::Name.last_name
  end
end
