# frozen_string_literal: true
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
  belongs_to :school
  belongs_to :age_range, inverse_of: :users
  belongs_to :cip_code, inverse_of: :users
  has_many :installments, inverse_of: :user, dependent: :destroy
  has_many :rosters, inverse_of: :user, dependent: :destroy
  has_many :courses, through: :projects

  has_many :reactions, inverse_of: :user, dependent: :destroy
  has_many :experiences, through: :reactions
  has_many :narratives, through: :experiences

  validates :timezone, :theme, presence: true

  has_many :assessments, through: :projects

  # Give us a standard form of the name
  def name
    if last_name.nil? && first_name.nil?
      name = email
    else
      name = (!last_name.nil? ? last_name : '[No Last Name Given]') + ', '
      name += (!first_name.nil? ? first_name : '[No First Name Given]')
    end
  end

  def waiting_consent_logs
    # Find those consent forms to which the user has not yet responded
    consent_forms = ConsentForm.all.to_a

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

  def waiting_instructor_tasks
    waiting_tasks = []

    rosters.instructorships.each do |roster|
      roster.course.bingo_games.each do |game|
        waiting_tasks << game if game.awaiting_review?
      end
    end

    waiting_tasks.sort_by(&:end_date)
  end

  def waiting_student_tasks
    waiting_tasks = assessments.still_open.to_a

    # Check available tasks for students
    available_rosters = rosters.enrolled

    available_rosters.each do |roster|
      waiting_tasks.concat roster.course.experiences
        .where('experiences.end_date >= ? AND experiences.start_date <= ? AND experiences.active = ?',
               DateTime.current, DateTime.current, true).to_a
    end

    available_rosters.each do |roster|
      waiting_games = roster.course.bingo_games
                            .where('bingo_games.end_date >= ? AND bingo_games.start_date <= ? AND bingo_games.active = ?',
                                   DateTime.current, DateTime.current, true).to_a
      waiting_games.delete_if { |game| !game.is_open? && !game.reviewed }
      waiting_tasks.concat waiting_games
    end

    waiting_tasks.sort_by(&:end_date)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.joins(:emails).where(emails: { email: data['email'] }).first

    # Uncomment the section below if you want users to be created if they don't exist
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
end
