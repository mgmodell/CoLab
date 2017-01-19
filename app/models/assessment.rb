class Assessment < ActiveRecord::Base
  belongs_to :project, :inverse_of => :assessments
  validates :end_date, :start_date, :presence => true

  #Helpful scope
  scope :still_open, -> { where( "assessments.end_date >= ?", Date.today ) }

  def is_completed_by_user( user )
    0 != user.installments.where( assessment: self ).count
  end

  def self.build_new_assessment( project )
    init_date = Date.today.beginning_of_day
    init_day = init_date.wday
    assessment = Assessment.new

    day_delta = init_day - project.start_dow
    if day_delta == 0
      assessment.start_date = init_date
    else
      assessment.start_date = Chronic.parse( "last " +  Date::DAYNAMES[ project.start_dow ] )
    end

    day_delta = project.end_dow - init_day
    if day_delta == 0
      assessment.end_date = init_date.beginning_of_day
    else
      assessment.end_date = Chronic.parse( "this " +  Date::DAYNAMES[ project.end_dow ] )
    end

    existing_assessment_count = project.assessments.where(
      "start_date = ? AND end_date = ?",
      assessment.start_date.to_date, assessment.end_date.to_date ).count


    if( existing_assessment_count == 0 )
      assessment.project = project
      assessment.save
    end
  end

  def self.set_up_assessments
    #TODO: Add timezone support here
    init_date = Date.today.beginning_of_day
    init_day = init_date.wday
    Project.where(
      "active = true AND start_date <= ? AND end_date >= ?",
    init_date, init_date.end_of_day ).each do |project|

      if( project.is_available? )
        self.build_new_assessment project
      end
    end
  end

end
