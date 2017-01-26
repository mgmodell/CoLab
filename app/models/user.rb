class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_and_belongs_to_many :groups
  has_many :consent_logs, inverse_of: :user
  has_many :projects, through: :groups
  belongs_to :gender, inverse_of: :users
  belongs_to :age_range, inverse_of: :users
  belongs_to :cip_code, inverse_of: :users
  has_many :installments, inverse_of: :user
  has_many :rosters, inverse_of: :user

  validates :timezone, presence: true

  has_many :assessments, through: :projects

  # Give us a standard form of the name
  def name
    name = (!last_name.nil? ? last_name : '[No Last Name Given]') + ', '
    name += (!first_name.nil? ? first_name : '[No First Name Given]')
  end

  def waiting_consent_logs
    # Find those consent forms to which the user has not yet responded
    consent_forms = ConsentForm.all.to_a

    puts "CFs: " + consent_forms.count.to_s
    puts "CLs: " + consent_logs.where( :presented => true ).count.to_s

    #Have we completed it already?
    consent_logs.where( :presented => true ).each do |consent_log|
      consent_forms.delete(consent_log.consent_form)
    end

    #Is it from a project that we're not in?
    projects_array = projects.to_a
    consent_forms.each do |consent_form|
      consent_form.projects.each do |cf_project|
        if !consent_form.global? && !projects_array.include?( cf_project )
          consent_forms.delete(consent_form)
          break
        end
      end
    end

    puts "Found: " + consent_forms.count.to_s
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
    if admin || Roster.instructorships.where('user_id = ?', id).count > 0
      true
    else
      false
    end
  end

  def waiting_installments
    ows = []

    assessments.still_open.each do |assessment|
      group = groups.joins(project: :assessments)
      if group.count == 1
        ows << [group[0], assessment]
      else
        logger.debug 'We have a problem!'
      end
    end

    ows
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(
        email: data['email'],
        password: Devise.friendly_token[0, 20]
      )
    end
    user
  end
end
