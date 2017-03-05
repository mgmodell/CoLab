class Group < ActiveRecord::Base
  belongs_to :project, inverse_of: :groups
  has_and_belongs_to_many :users, inverse_of: :groups

  has_many :installments, inverse_of: :group, dependent: :destroy

  validates :name, :project_id, presence: true
  validate :validate_activation_status, on: :update

  def validate_activation_status
    if (!project.nil? && project.active) ||
       (project.changed? && !project_id_was.nil? &&
       Project.find(project_id_was).active)
      errors.add(:project,
                 'This group is part of a project with an active assessment. ' \
                 'Please deactivate the project before making changes.')

    end
  end

  def has_user(user)
    users.where('users.id = ?', user.id).any?
  end
end
