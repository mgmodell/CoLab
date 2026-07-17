# frozen_string_literal: true

require 'faker'

class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User
  include DeviseTokenAuth::Concerns::ResourceFinder
  include DeviseTokenAuth::Concerns::UserOmniauthCallbacks

  has_many :emails, inverse_of: :user, dependent: :destroy

  devise :multi_email_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :multi_email_validatable, :multi_email_confirmable,
         :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_and_belongs_to_many :groups
  has_many :consent_logs, inverse_of: :user, dependent: :destroy

  has_many :rosters, inverse_of: :user, dependent: :destroy, autosave: true
  has_many :candidate_lists, inverse_of: :user, dependent: :destroy
  has_many :bingo_boards, inverse_of: :user, dependent: :destroy
  has_many :candidates, inverse_of: :user, dependent: :nullify

  has_many :courses, through: :rosters

  has_many :bingo_games, through: :courses
  has_many :projects, through: :groups

  has_many :concepts, through: :candidates

  belongs_to :gender, inverse_of: :users, optional: true
  delegate :code, to: :gender, prefix: true

  has_one :home_country, through: :home_state
  delegate :no_response, to: :home_country, prefix: true

  belongs_to :home_state, inverse_of: :users, optional: true
  delegate :no_response, :home_country, to: :home_state, prefix: true

  belongs_to :cip_code, inverse_of: :users, optional: true
  delegate :zero, :gov_code, to: :cip_code, prefix: true

  belongs_to :language, inverse_of: :users, optional: true
  belongs_to :primary_language, inverse_of: :home_users,
                                class_name: 'Language', optional: true
  delegate :code, to: :primary_language, prefix: true

  belongs_to :school, optional: true
  has_many :installments, inverse_of: :user, dependent: :destroy

  has_many :reactions, inverse_of: :user, dependent: :destroy
  has_many :experiences, through: :reactions
  has_many :narratives, through: :experiences

  has_many :rubrics, inverse_of: :user, dependent: :nullify
  has_many :submissions, inverse_of: :user, dependent: :destroy

  has_many :messages, class_name: 'Ahoy::Message', dependent: :nullify

  validates :timezone, presence: true

  has_many :assessments, through: :projects

  before_save :anonymize

  # Give us a standard form of the name
  def name( anonymous )
    if anonymous
      "#{anon_last_name}, #{anon_first_name}"
    elsif last_name.nil? && first_name.nil?
      email
    else
      name = "#{!last_name.nil? ? last_name : '[No Last Name Given]'}, "
      name + ( !first_name.nil? ? first_name : '[No First Name Given]' )
    end
  end

  def get_first_name( anonymous )
    if anonymous
      anon_first_name
    elsif first_name.nil?
      '[No First Name Given]'
    else
      first_name
    end
  end

  def get_last_name( anonymous )
    if anonymous
      anon_last_name
    elsif last_name.nil?
      '[No Last Name Given]'
    else
      last_name
    end
  end

  def get_school_name( anonymous )
    if anonymous
      school.anon_name || '[No School Given]'
    else
      school.name || '[No School Given]'
    end
  end

  def informal_name( anonymous )
    if anonymous
      "#{anon_first_name} #{anon_last_name}"
    elsif last_name.nil? && first_name.nil?
      email
    else
      name = "#{!first_name.nil? ? first_name : '[No First Name Given]'} "
      name + ( !last_name.nil? ? last_name : '[No Last Name Given]' )
    end
  end

  def language_code
    language&.code
  end

  def anonymize?
    researcher
  end

  def waiting_consent_logs
    # Get logs tied to courses
    logs = {}

    consent_logs.joins( :consent_form )
                .where( consent_forms: { active: true } )
                .find_each do | consent_log |
      logs[consent_log.consent_form_id] = consent_log
    end

    courses.includes( consent_form: :consent_logs )
           .where( 'courses.consent_form_id IS NOT NULL' )
           .find_each do | course |
      if course.consent_form_active && logs[course.consent_form_id].nil?
        log = course.get_consent_log user: self
        logs[log.consent_form_id] = log unless log.nil?
      end
    end

    now = Time.zone.today
    # Find those consent forms to which the user has not yet responded
    # We only want to do this for currently active consent forms
    consent_forms = ConsentForm.global_active_at( now ).to_a

    consent_forms.each do | consent_form |
      next unless logs[consent_form.id].nil?

      log = consent_logs.create( consent_form_id: consent_form.id, presented: false )
      logs[consent_form.id] = log
    end

    logs.values.delete_if( &:presented )
  end

  def is_admin?
    admin.nil? ? false : admin
  end

  def is_instructor?
    instructor.nil? ? false : instructor
  end

  def is_researcher?
    researcher.nil? ? false : researcher
  end

  def update_instructor
    self.instructor = if admin || rosters.instructor.count.positive?
                        true
                      else
                        false
                      end
  end

  def waiting_instructor_tasks
    waiting_tasks = []

    BingoGame.joins( course: :rosters )
             .includes( :course )
             .where( 'rosters.user_id': id )
             .and( Roster.faculty )
             .find_each do | game |
      waiting_tasks << game if game.awaiting_review?
    end

    cur_date = DateTime.current
    Assignment.joins( :submissions, course: :rosters )
              .where( 'rosters.user_id': id )
              .where( 'assignments.end_date >= ?', cur_date )
              .and( Submission.where.not( submitted: nil ) )
              .and( Submission.where( withdrawn: nil ) )
              .and( Submission.where( recorded_score: nil ) )
              # .and(Submission.where('recorded_score < 0'))
              .and( Roster.faculty )
              .find_each do | submission |
      waiting_tasks << submission
    end

    waiting_tasks.sort_by( &:end_date )
  end

  def activity_history
    activities = []
    # Add in the candidate lists
    BingoGame.joins( course: :rosters )
             .includes( :course, :project )
             .where( reviewed: true, 'rosters.user_id': id )
             .and( Roster.enrolled )
             .all.find_each do | bingo_game |
      activities << bingo_game
    end
    # Add in the reactions
    activities.concat experiences.includes( :course ).all

    # Add in projects
    activities.concat projects.includes( :course ).all

    # Add in assignments
    Assignment.joins( course: :rosters )
              .includes( :course, :submissions )
              .where( 'rosters.user_id': id )
              .and( Roster.enrolled )
              .all.find_each do | assignment |
      activities << assignment
    end

    activities.sort_by( &:end_date )
  end

  def get_bingo_performance( course_id: 0 )
    my_candidate_lists = []
    if course_id.positive?
      my_candidate_lists.concat candidate_lists
        .includes( candidates: :candidate_feedback,
                   bingo_game: :project )
        .joins( :bingo_game )
        .where( bingo_games:
                              { reviewed: true, course_id: } )
        .to_a

    else
      my_candidate_lists.concat candidate_lists
        .includes( candidates: :candidate_feedback,
                   bingo_game: :project )
        .joins( :bingo_game )
        .where( bingo_games:
                              { reviewed: true } )
        .to_a
    end
    my_candidate_lists.each_with_index do | solo_cl, index |
      next unless solo_cl.archived

      my_candidate_lists[index] = solo_cl.current_candidate_list
    end

    total = 0
    my_candidate_lists.each do | candidate_list |
      total += candidate_list.performance
    end
    my_candidate_lists.empty? ? 100 : ( total / my_candidate_lists.size )
  end

  def get_bingo_data( course_id: 0 )
    my_candidate_lists = []
    if course_id.positive?
      my_candidate_lists.concat candidate_lists
        .includes( candidates: :candidate_feedback,
                   bingo_game: :project )
        .joins( :bingo_game )
        .where( bingo_games:
                              { reviewed: true, course_id: } )
        .to_a

    else
      my_candidate_lists.concat candidate_lists
        .includes( candidates: :candidate_feedback,
                   bingo_game: :project )
        .joins( :bingo_game )
        .where( bingo_games:
                              { reviewed: true } )
        .to_a
    end
    my_candidate_lists.each_with_index do | solo_cl, index |
      next unless solo_cl.archived

      my_candidate_lists[index] = solo_cl.current_candidate_list
    end

    data = []
    my_candidate_lists.each do | candidate_list |
      data << candidate_list.performance
    end
    data
  end

  def get_experience_performance( course_id: 0 )
    my_reactions = if course_id.positive?
                     reactions.includes( :narrative ).joins( :experience )
                              .where( experiences: { course_id: } )
                   else
                     reactions
                   end

    total = 0
    my_reactions.includes( :behavior ).find_each do | reaction |
      total += reaction.status
    end
    my_reactions.count.zero? ? 100 : ( total / my_reactions.count )
  end

  def get_assessment_performance( course_id: 0 )
    my_projects = if course_id.positive?
                    projects.includes( :assessments ).where( course_id: )
                  else
                    projects.includes( :assessments )
                  end

    total = 0
    my_projects.each do | project |
      total += project.get_performance( self )
    end
    my_projects.count.zero? ? 100 : ( total / my_projects.count )
  end

  def waiting_student_tasks
    cur_date = DateTime.current
    waiting_tasks = assessments.includes( course: :consent_form ).active_at( cur_date ).to_a

    # Check available tasks for students

    # Add the experiences
    waiting_experiences = Experience.active_at( cur_date )
                                    .includes( course: :consent_form )
                                    .joins( course: :rosters )
                                    .where( rosters: { user_id: id } )
                                    .where( rosters: { role: [Roster.roles[:enrolled_student],
                                                              Roster.roles[:invited_student]] } )
                                    .to_a

    waiting_experiences.delete_if { | experience | !experience.is_open? }

    waiting_tasks.concat waiting_experiences

    # Add the bingo games
    waiting_games = BingoGame.joins( course: :rosters )
                             .includes( { course: :consent_form }, :project )
                             .where( rosters: { user_id: id }, bingo_games: { active: true } )
                             .where( rosters: { role: [Roster.roles[:enrolled_student],
                                                       Roster.roles[:invited_student]] } )
                             .where( 'bingo_games.end_date >= ? AND bingo_games.start_date <= ?', cur_date, cur_date )
                             .to_a

    waiting_games.delete_if { | game | !game.is_open? && !game.reviewed }
    waiting_tasks.concat waiting_games

    waiting_assignments = Assignment.joins( course: :rosters )
                                    .includes( { course: :consent_form }, :project )
                                    .where( rosters: { user_id: id }, assignments: { active: true } )
                                    .where( rosters: { role: [Roster.roles[:enrolled_student],
                                                              Roster.roles[:invited_student]] } )
                                    .where( 'assignments.end_date >= ? AND courses.start_date <= ?', cur_date, cur_date )
                                    .to_a

    waiting_tasks.concat waiting_assignments

    waiting_tasks.sort_by( &:end_date )
  end

  def self.from_omniauth( access_token )
    data = access_token
    user = User.joins( :emails ).where( emails: { email: data['email'] } ).first

    user ||= User.create(
      email: data['email'],
      password: Devise.friendly_token[0, 20],
      first_name: data['given_name'],
      last_name: data['family_name'],
      timezone: 'UTC'
    )
    user.confirm
    user
  end

  def self.merge_users( predator:, prey: )
    pred_u = User.find_by_email( predator )
    prey_u = User.find_by_email( prey )

    resp_hash = {}
    resp_hash[:success] = false

    if pred_u.present? && prey_u.present?
      rosters_count = pred_u.rosters.size + prey_u.rosters.size
      courses_count = pred_u.courses.size + prey_u.courses.size
      experiences_count = pred_u.experiences.size + prey_u.experiences.size
      bingo_count = pred_u.bingo_games.size + prey_u.bingo_games.size
      installments_count = pred_u.installments.size + prey_u.installments.size
      if courses_count != Course.joins( :rosters ).where( 'rosters.user_id': [pred_u.id,
                                                                              prey_u.id] ).distinct.count ||
         rosters_count != Roster.where( user_id: [pred_u.id, prey_u.id] ).distinct.count ||
         experiences_count != Reaction.where( user_id: [pred_u.id, prey_u.id] ).distinct.count ||
         bingo_count != BingoGame.joins( course: :rosters ).where( 'rosters.user_id': [pred_u.id,
                                                                                       prey_u.id] ).distinct.count ||
         installments_count != Installment.where( user_id: [pred_u.id, prey_u.id] ).distinct.count
        resp_hash[:errors] = ['merge_users_error_not_possible_msg']
      else
        # copy the demographic data
        User.transaction do
          prey_u.active = false
          prey_u.save!
          # Demographic data
          pred_u.first_name = pred_u.first_name || prey_u.first_name
          pred_u.last_name = pred_u.last_name || prey_u.last_name
          pred_u.gender_id = pred_u.gender_id || prey_u.gender_id
          pred_u.country = pred_u.country || prey_u.country
          pred_u.timezone = pred_u.timezone || prey_u.timezone
          pred_u.theme = pred_u.theme || prey_u.theme
          pred_u.school_id = pred_u.school_id || prey_u.school_id
          pred_u.language_id = pred_u.language_id || prey_u.language_id
          pred_u.date_of_birth = pred_u.date_of_birth || prey_u.date_of_birth
          pred_u.home_state_id = pred_u.home_state_id || prey_u.home_state_id
          pred_u.cip_code_id = pred_u.cip_code_id || prey_u.cip_code_id
          pred_u.primary_language_id = pred_u.primary_language_id || prey_u.primary_language_id
          pred_u.started_school = pred_u.started_school || prey_u.started_school
          pred_u.impairment_visual = pred_u.impairment_visual || prey_u.impairment_visual
          pred_u.impairment_auditory = pred_u.impairment_auditory || prey_u.impairment_auditory
          pred_u.impairment_motor = pred_u.impairment_motor || prey_u.impairment_motor
          pred_u.impairment_cognitive = pred_u.impairment_cognitive || prey_u.impairment_cognitive
          pred_u.impairment_other = pred_u.impairment_other || prey_u.impairment_other
          # Capabilities/permissions setting
          pred_u.admin = pred_u.admin || prey_u.admin
          pred_u.researcher = pred_u.researcher || prey_u.researcher
          pred_u.instructor = pred_u.instructor || prey_u.instructor
          pred_u.welcomed = pred_u.welcomed || prey_u.welcomed
          pred_u.last_emailed = pred_u.last_emailed || prey_u.last_emailed

          prey_u.groups.each do | g |
            g.users.delete prey_u
            g.users << pred_u
          end
          prey_u.bingo_boards.update_all user_id: pred_u.id
          prey_u.candidate_lists.update_all user_id: pred_u.id
          prey_u.candidates.update_all user_id: pred_u.id
          ConsentForm.where( user: prey_u ).update_all user_id: pred_u.id
          prey_u.consent_logs.update_all user_id: pred_u.id
          prey_u.installments.update_all user_id: pred_u.id
          prey_u.reactions.update_all user_id: pred_u.id
          prey_u.rubrics.update_all user_id: pred_u.id
          prey_u.submissions.update_all user_id: pred_u.id

          prey_u.rosters.update_all user_id: pred_u.id

          prey_u.rubrics.update_all user_id: pred_u.id
          prey_u.submissions.update_all user_id: pred_u.id
          Value.where( user: prey_u ).update_all user_id: pred_u.id

          # Ahoy email message tracking
          Ahoy::Message.where( user: prey_u ).update_all user_id: pred_u.id

          # Remap all user_ids
          # prey_u.emails.update_all user_id: pred_u.id
          prey_u.emails.each do | email |
            pred_u.emails << email
          end

          pred_u.save!
          prey_u.destroy!
          errors = []
          if pred_u.errors.any? || prey_u.errors.any?
            resp_hash[:success] = false
            resp_hash[:errors] = []

            errors << pred_u.errors.full_messages unless pred_u.errors.empty?
            errors << prey_u.errors.full_messages unless prey_u.errors.empty?
            resp_hash[:errors] = errors.flatten

          else
            resp_hash[:success] = true
            resp_hash[:errors] = []
            resp_hash[:message] = 'merge_users_success_msg'
          end
        end
      end
    else
      logger.debug I18n.t( 'one_or_more_users_not_found_msg' )
      resp_hash[:errors] = ['one_or_more_users_not_found_msg']
    end
    resp_hash
  end

  private

  def anonymize
    if gender.present? && gender.changed?
      self.anon_first_name = case gender.code
                             when 'm'
                               Faker::Name.male_first_name
                             when 'f'
                               Faker::Name.female_first_name
                             else
                               Faker::Name.first_name
                             end
      self.anon_last_name = Faker::Name.last_name
    end
    self.anon_first_name ||= Faker::Name.first_name
    self.anon_last_name ||= Faker::Name.last_name
  end
end
