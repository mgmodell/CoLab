# frozen_string_literal: true

class Roster < ApplicationRecord
  belongs_to :course, inverse_of: :rosters
  delegate :name, to: :course, prefix: true

  belongs_to :user, inverse_of: :rosters

  after_update :clean_up_dropped
  after_create :set_instructor

  enum role: { instructor: 1, assistant: 2, enrolled_student: 3,
               invited_student: 4, declined_student: 5,
               dropped_student: 6, requesting_student: 7,
               rejected_student: 8 }

  validates :user_id, uniqueness: { scope: :course_id }

  scope :faculty, lambda {
    where( role: [roles[:instructor],
                  roles[:assistant]] )
  }
  scope :students, lambda {
    where( role: [roles[:enrolled_student],
                  roles[:invited_student],
                  roles[:declined_student]] )
  }
  scope :enrolled, lambda {
    where( role: [roles[:enrolled_student],
                  roles[:invited_student]] )
  }

  private

  # In this method, we will remove ourselves from any groups that are no longer valid for us
  def clean_up_dropped
    if dropped_student?
      ActiveRecord::Base.transaction do
        course.projects.includes( groups: :users ).find_each do | project |
          project.groups.each do | group |
            next unless group.users.includes( user )

            project = group.project
            activation_status = project.active
            group.users.delete( user )
            group.save!
            logger.debug group.errors.full_messages unless group.errors.empty?
            project = group.project
            project.reload
            project.active = activation_status
            project.save!
            logger.debug project.errors.full_messages unless project.errors.empty?
          end
        end
      end
    end
    user.update_instructor
    user.save!
  end

  def set_instructor
    user.update_instructor
    user.save!
  end
end
