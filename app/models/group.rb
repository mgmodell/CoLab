class Group < ActiveRecord::Base

  belongs_to :project, :inverse_of => :groups
  has_and_belongs_to_many :users, :inverse_of => :groups

  has_many :installments, :inverse_of => :group

  validates :name, :project_id, :presence => true
  validate :validate_activation_status, :on => :update

  def validate_activation_status
    if ( !project.nil? && project.active ) ||
        ( self.project.changed? && !self.project_id_was.nil? &&
        Project.find( self.project_id_was ).active )
      errors.add( :project, 
        "This group is part of a project with an active assessment. " +
        "Please deactivate the project before making changes." )

    end

  end

end
