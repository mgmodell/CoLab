class Project < ActiveRecord::Base
  belongs_to :course
  has_many :groups
  has_many :assessments
  belongs_to :course

  has_many :users, :through => :groups

  validates :name, :end_dow, :start_dow, :presence => true
  validates :end_date, :start_date, :presence => true

  validates :start_dow, :end_dow, :numericality => {
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 6 }

  #Let's be sure the dates are valid
  validate :validate_date_sanity
  validate :validate_activation_status

   def get_user_appearance_counts
      Project.get_occurence_count_hash user
   end

   def get_group_appearance_counts
      Project.get_occurence_count_hash group
   end
   
   def self.get_occurence_count_hash input_array
      dup_hash = Hash.new( 0 )
      input_array.each{ |v| dup_hash.store( v, dup_hash[v]+1 ) }
      dup_hash
   end

  #Validation check code
  def validate_date_sanity
    if self.start_date > self.end_date
      errors.add( :start_dow, "The start date must come before the end date" )
    end
    errors
  end

  def validate_activation_status
      if self.active_was && self.active
         errors.add( :active, "You cannot make changes to an active project. Please deactivate it first." )
      elsif !self.active_was && self.active
         self.get_user_appearance_counts.each do |user_id, count|
            #Check the users
            if count > 1
               user = User.find( user_id )
               errors.add( :active, "#{user.name} appears #{count} times in your project." )
            end
         end
         #Check the groups
         self.get_group_appearance_counts.each do |group_id, count|
            if count > 1
               group = Group.find( group_id )
               errors.add( :active, "#{group.name} (group) appears #{count} times in your project." )
            end
         end
         #If this is an activation, we need to set up any necessary weeklies
         if errors.count < 1
            if self.is_available?
               Weekly.build_new_weekly self

            end
         end
      end
      errors

  end
end
