class User < ActiveRecord::Base
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
   :recoverable, :rememberable, :trackable, :validatable,
   :confirmable, :lockable, 
   :omniauthable, :omniauth_providers => [:google_oauth2]

   has_and_belongs_to_many :groups

   #Give us a standard form of the name
   def name
      name = (self.last_name != nil ? self.last_name : "[No Last Name Given]") + ", "
      name += (self.first_name != nil ? self.first_name : "[No First Name Given]")
   end

   def waiting_consent_logs
      #Find the unpresented consent_logs
      consent_logs = Hash.new

      ConsentLog.where( "user_id = ?", self.id).each do |consent_log|
         consent_logs.store( consent_log.consent_form_id, consent_log )
      end
      self.consent_form_ids.each do |consent_form_id|
         if consent_logs[ consent_form_id ].nil?
            consent_logs.store( consent_form_id, ConsentLog.new( :consent_form_id => consent_form_id,
            :user_id => self.id,
            :presented => false,
            :accepted => false ) )
         end
      end
      consent_logs.delete_if{|consent_form_id,consent_log| consent_log.presented}
      consent_logs.values
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

   def open_group_reports
      ows = []
      self.groups.each do |group|
         if( !group.project.nil? &&
            !group.project.nil? &&
            !group.project.weeklies.nil? )
            weeklies = group.project.weeklies.
            where( "end_date >= ?", Date.today)
            if !weeklies.blank?
               ows << [ group, weeklies[ 0 ] ]
            end
         end
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
