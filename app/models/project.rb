class Project < ActiveRecord::Base
  after_save :build_assessment

  belongs_to :course, :inverse_of => :projects
  belongs_to :style, :inverse_of => :projects
  has_many :groups, :inverse_of => :project
  has_many :assessments, :inverse_of => :project
  belongs_to :course, :inverse_of => :projects
  belongs_to :consent_form, :inverse_of => :projects
  belongs_to :factor_pack, :inverse_of => :projects

  has_many :users, :through => :groups
  has_many :factors, :through => :factor_pack

  validates :name, :end_dow, :start_dow, :presence => true
  validates :end_date, :start_date, :presence => true

  before_save :timezone_adjust

  validates :start_dow, :end_dow, :numericality => {
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 6 }

  #Let's be sure the dates are valid
  validate :date_sanity
  validate :dates_within_course
  validate :activation_status

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
      input_array.each{ |v| dup_hash.store( v.id, dup_hash[v.id]+1 ) }
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
  def date_sanity
    if self.start_date > self.end_date
      errors.add( :start_dow, "The start date must come before the end date" )
    end
    errors
  end

  def dates_within_course
    if start_date < course.start_date
      errors.add( :start_date, "The project cannot begin before the course has begun" )
    end
    if end_date > course.end_date
      errors.add( :end_date, "The project cannot continue after the course has ended" )
    end
    errors

  end

  def activation_status
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
      end
      errors

  end

  #Handler for building an assessment, if necessary
  def build_assessment
    #Nothing needs to be done unless we're active
    if self.active? && self.is_available?
      Assessment.build_new_assessment self
    end
  end

  def timezone_adjust
    if start_date.zone != course.timezone
      start_date = ActiveSupport::TimeZone.new( course.timezone ).local_to_utc( start_date.beginning_of_day )
      end_date = ActiveSupport::TimeZone.new( course.timezone ).local_to_utc( end_date.end_of_day )
    end

  end
end
