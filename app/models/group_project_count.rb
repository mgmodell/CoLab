# frozen_string_literal: true
class GroupProjectCount < ActiveRecord::Base
  has_many :users, inverse_of: :group_project_count
end
