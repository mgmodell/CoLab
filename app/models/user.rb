class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable,
  :confirmable, :lockable, 
  :omniauthable, :omniauth_providers => [:google_oauth2]

  has_and_belongs_to_many :groups
  has_many :consent_logs
  has_many :projects, :through => :groups
  belongs_to :gender
  belongs_to :age_range

  has_many :assessments, :through => :projects

  #Give us a standard form of the name
  def name
    name = (self.last_name != nil ? self.last_name : "[No Last Name Given]") + ", "
    name += (self.first_name != nil ? self.first_name : "[No First Name Given]")
  end

  def waiting_consent_logs
    #Find those consent forms to which the user has not yet responded
    consent_forms = ConsentForm.all.to_a
    self.consent_logs.each do |consent_log|
      consent_forms.delete( consent_log.consent_form )
    end

    #Create consent logs for waiting consent forms
    waiting_consent_logs = Array.new
    consent_forms.each do |w_consent_form|
      consent_log = ConsentLog.new( user: self, consent_form: w_consent_form )
      waiting_consent_logs << consent_log
    end
    waiting_consent_logs
      
  end

  def is_admin?
    self.admin
  end

  def is_instructor?
    if self.admin || Roster.instructorships.where( "user_id = ?", self.id ).count > 0
      return true
    else
      return false
    end
  end

  def waiting_installments
    ows = []
    self.assessments.still_open.each do |assessment|
      ows << [ group, assessments[ 0 ] ]
    end

    return ows
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(
        email: data["email"],
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

end
