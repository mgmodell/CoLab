# frozen_string_literal: true

require 'forgery'

class User < ApplicationRecord
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
  has_many :bingo_games, through: :courses
  has_many :bingo_boards, inverse_of: :user
  has_many :candidates, inverse_of: :user
  belongs_to :gender, inverse_of: :users, optional: true
  belongs_to :theme, inverse_of: :users, optional: true
  has_one :home_country, through: :home_state
  belongs_to :home_state, inverse_of: :users, optional: true
  belongs_to :cip_code, inverse_of: :users, optional: true

  belongs_to :language, inverse_of: :users, optional: true
  belongs_to :primary_language, inverse_of: :home_users,
                                class_name: 'Language', optional: true

  belongs_to :school, optional: true
  has_many :installments, inverse_of: :user, dependent: :destroy
  has_many :rosters, inverse_of: :user, dependent: :destroy
  has_many :courses, through: :projects

  has_many :reactions, inverse_of: :user, dependent: :destroy
  has_many :experiences, through: :reactions
  has_many :narratives, through: :experiences

  has_many :messages, class_name: 'Ahoy::Message'

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
    now = Date.today
    # Find those consent forms to which the user has not yet responded
    # We only want to do this for currently active consent forms
    consent_forms = ConsentForm.active_at(now)
                               .includes(:projects)
                               .to_a

    consent_logs.where(presented: true).each do |consent_log|
      consent_forms.delete_if { |consent_form| consent_form.id == consent_log.consent_form_id }
    end

    # Is it from a project that we're not in?
    projects_array = projects.to_a
    consent_forms.each do |consent_form|
      next if consent_form.global?
      consent_form.projects.each do |cf_project|
        unless projects_array.include?(cf_project)
          consent_forms.delete(consent_form)
          break
        end
      end
    end

    # Create consent logs for waiting consent forms
    waiting_consent_logs = []
    consent_forms.each do |w_consent_form|
      consent_log = consent_logs.new(consent_form: w_consent_form)
      waiting_consent_logs << consent_log
    end
    waiting_consent_logs
  end

  def is_admin?
    admin
  end

  def is_instructor?
    if admin || rosters.instructor.count > 0
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

    BingoGame.joins(course: :rosters)
             .includes(:course)
             .where('rosters.user_id': id, 'rosters.role': Roster.roles[:instructor])
             .find_each do |game|
      waiting_tasks << game if game.awaiting_review?
    end

    waiting_tasks.sort_by(&:end_date)
  end

  def activity_history
    activities = []
    # Add in the candidate lists
    BingoGame.joins(course: :rosters)
             .includes(:project)
             .where(reviewed: true, 'rosters.user_id': id)
             .where('rosters.role = ? OR rosters.role = ?',
                    Roster.roles[:enrolled_student], Roster.roles[:invited_student])
             .all.each do |bingo_game|

      activities << bingo_game
    end
    # Add in the reactions
    activities.concat experiences.includes(:course).all

    # Add in projects
    activities.concat projects.includes(:course).all

    activities.sort_by(&:end_date)
  end

  def get_bingo_performance(course_id: 0)
    my_candidate_lists = []
    if course_id > 0
      my_candidate_lists.concat candidate_lists
        .includes(candidates: :candidate_feedback,
                  bingo_game: :project)
        .joins(:bingo_game)
        .where(bingo_games:
                              { reviewed: true, course_id: course_id })
        .to_a

    else
      my_candidate_lists.concat candidate_lists
        .includes(candidates: :candidate_feedback,
                  bingo_game: :project)
        .joins(:bingo_game)
        .where(bingo_games:
                              { reviewed: true })
        .to_a
    end
    my_candidate_lists.each_with_index do |solo_cl, index|
      next unless solo_cl.is_group
      group_cl = solo_cl.bingo_game.candidate_lists
                        .where(group_id: solo_cl.bingo_game.project
                      .group_for_user(self).id)
                        .take
      my_candidate_lists[index] = group_cl
    end

    unless my_candidate_lists.empty?
      total = my_candidate_lists
              .inject(my_candidate_lists[0].performance) { |sum, cl| sum + cl.performance }
    end
    my_candidate_lists.count == 0 ? 100 : (total / my_candidate_lists.count)
  end

  def get_bingo_data(course_id: 0)
    my_candidate_lists = []
    if course_id > 0
      my_candidate_lists.concat candidate_lists
        .includes(candidates: :candidate_feedback,
                  bingo_game: :project)
        .joins(:bingo_game)
        .where(bingo_games:
                              { reviewed: true, course_id: course_id })
        .to_a

    else
      my_candidate_lists.concat candidate_lists
        .includes(candidates: :candidate_feedback,
                  bingo_game: :project)
        .joins(:bingo_game)
        .where(bingo_games:
                              { reviewed: true })
        .to_a
    end
    my_candidate_lists.each_with_index do |solo_cl, index|
      next unless solo_cl.is_group
      group_cl = solo_cl.bingo_game.candidate_lists
                        .where(group_id: solo_cl.bingo_game.project
                      .group_for_user(self).id)
                        .take
      my_candidate_lists[index] = group_cl
    end

    data = []
    my_candidate_lists.each do |candidate_list|
      data << candidate_list.performance
    end
    data
  end

  def get_experience_performance(course_id: 0)
    my_reactions = []
    my_reactions = if course_id > 0
                     reactions.includes(:narrative).joins(:experience)
                              .where(experiences: { course_id: course_id })
                   else
                     reactions
                   end

    total = 0
    my_reactions.includes(:behavior).each do |reaction|
      total += reaction.status
    end
    my_reactions.count == 0 ? 100 : (total / my_reactions.count)
  end

  def get_assessment_performance(course_id: 0)
    my_projects = []
    my_projects = if course_id > 0
                    projects.includes(:assessments).where(course_id: course_id)
                  else
                    projects.includes(:assessments)
                  end

    total = 0
    my_projects.each do |project|
      total += project.get_performance(self)
    end
    my_projects.count == 0 ? 100 : (total / my_projects.count)
  end

  def waiting_student_tasks
    cur_date = DateTime.current
    waiting_tasks = assessments.includes(project: %i[course consent_form]).active_at(cur_date).to_a

    # Check available tasks for students
    available_rosters = rosters.enrolled

    # Add the experiences

    waiting_tasks.concat Experience.active_at(cur_date).joins(course: :rosters)
      .where('rosters.user_id': id)
                                   .where('rosters.role IN (?)',
                                          [Roster.roles[:enrolled_student], Roster.roles[:invited_student]])
                                   .to_a
    # Add the bingo games
    waiting_games = BingoGame.joins(course: :rosters)
                             .includes(:course, :project)
                             .where('rosters.user_id': id, 'bingo_games.active': true)
                             .where('rosters.role = ? OR rosters.role = ?',
                                    Roster.roles[:enrolled_student], Roster.roles[:invited_student])
                             .where('bingo_games.end_date >= ? AND bingo_games.start_date <= ?', cur_date, cur_date)
                             .to_a

    waiting_games.delete_if { |game| !game.is_open? && !game.reviewed }
    waiting_tasks.concat waiting_games

    waiting_tasks.sort_by(&:end_date)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.joins(:emails).where(emails: { email: data['email'] }).first

    user ||= User.create(
      email: data['email'],
      password: Devise.friendly_token[0, 20],
      timezone: 'UTC'
    )
    user.confirm
    user
  end

  private

  def anonymize
    self.anon_first_name = Forgery::Name.first_name
    self.anon_last_name = Forgery::Name.last_name
  end
end
