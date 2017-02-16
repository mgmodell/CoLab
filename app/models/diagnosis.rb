class Diagnosis < ActiveRecord::Base
  belongs_to :behavior, inverse_of: :diagnoses
  belongs_to :reaction, inverse_of: :diagnoses
  belongs_to :week, inverse_of: :diagnoses

  has_one :user, through: :reaction

  validates :behavior, presence: { message: "You must select a behavior." }

  validate :validate_other_name
  validate :validate_unique

  def validate_other_name
    if !self.behavior_id.nil? &&
      Behavior.find( self.behavior_id ).name == "Other" &&
      ( self.other_name.nil? || self.other_name.empty? )
      
      errors.add( :other_name, "Please indicate the name of the behavior you identify in this narrative." )
    end
  end

  def validate_unique
    if Diagnosis.where( reaction: self.reaction, week_id: self.week_id ).exists?
      errors[ :base] << "Please do not use either the 'back' or 'reload' buttons." +
        "You are being returned to correct week."
    end
  end
end
