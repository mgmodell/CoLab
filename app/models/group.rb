# frozen_string_literal: true
class Group < ActiveRecord::Base
  belongs_to :project, inverse_of: :groups
  has_and_belongs_to_many :users, inverse_of: :groups

  has_many :installments, inverse_of: :group, dependent: :destroy

  validates :name, :project_id, presence: true
  validate :validate_activation_status, on: :update

  def validate_activation_status
    if( project_id_was != project_id )
      errors.add(:project,
                 'It is not possible to move a group from one project to another.' )
    end
    if self.changed?
      project.active = false
      project.save
    end
  end

  def has_user(user)
    users.where('users.id = ?', user.id).any?
  end
end
