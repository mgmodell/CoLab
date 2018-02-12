# frozen_string_literal: true

class Roster < ApplicationRecord
  belongs_to :course, inverse_of: :rosters
  belongs_to :user, inverse_of: :rosters

  after_update :clean_up_dropped

  enum role: { instructor: 1, assistant: 2, enrolled_student: 3,
               invited_student: 4, declined_student: 5,
               dropped_student: 6 }
  validates_uniqueness_of :user_id, scope: :course_id

  scope :faculty, -> {
    where(role: [roles[:instructor],
                 roles[:assistant]])
  }
  scope :students, -> {
    where(role: [roles[:enrolled_student],
                 roles[:invited_student],
                 roles[:declined_student]])
  }
  scope :enrolled, -> {
    where(role: [roles[:enrolled_student],
                 roles[:invited_student]])
  }

  private

  # In this method, we will remove ou
  def clean_up_dropped
    if dropped_student?
      course.projects.includes(groups: :users).each do |project|
        project.groups.each do |group|
          next unless group.users.includes(user)
          project = group.project
          activation_status = project.active
          group.users.delete(user)
          group.save
          puts group.errors.full_messages unless group.errors.empty?
          project = group.project
          project.reload
          project.active = activation_status
          project.save
          puts project.errors.full_messages unless project.errors.empty?
        end
      end
    end
  end
end
