class Project < ActiveRecord::Base
  belongs_to :course
  has_many :groups
  has_many :assessments
  belongs_to :course
  belongs_to :consent_form
  belongs_to :behaviour_pack

  has_many :users, :through => :groups
  has_many :behaviours, :through => :behaviour_pack

  validates :name, :end_dow, :start_dow, :presence => true
  validates :end_date, :start_date, :presence => true

  validates :start_dow, :end_dow, :numericality => {
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 6 }

  #Let's be sure the dates are valid
  validate :validate_date_sanity
  validate :validate_activation_status

   def is_for_research?
      ! self.consent_form.nil?
   end

   def number_of_weeks
      ( self.end_date - self.start_date ).divmod( 7 )[0]
   end

   def get_user_appearance_counts
      Project.get_occurence_count_hash users
   end

   def get_group_appearance_counts
      Project.get_occurence_count_hash groups
   end
   
   def self.get_occurence_count_hash input_array
      dup_hash = Hash.new( 0 )
      input_array.each{ |v| dup_hash.store( v.id, dup_hash[v]+1 ) }
      dup_hash
   end

   # If the date range wraps from Saturday to Sunday, it's not inside.
   def has_inside_date_range?
      has_inside_date_range = false
      if( self.start_dow <= self.end_dow )
         has_inside_date_range = true
      end
      has_inside_date_range
   end


   # Check if the assessment is active, if we're in the date range and
   # within the day range.
   def is_available?
      is_available = false
      init_time = Time.now
      init_day = init_time.wday
      init_date = init_time.to_date

      if( self.active &&
         self.start_date < init_date && self.end_date > init_date )
         if( self.has_inside_date_range? )
            if( self.start_dow <= init_day && self.end_dow >= init_day )
               is_available = true
            end
         else

            if( !( init_day < self.start_dow && self.end_dow < init_day ) )
               is_available = true
            end
         end
      end
      logger.debug is_available
      is_available
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
         #TODO: Make sure we build any necessary new assessments on activations
      end
      errors

  end
end
