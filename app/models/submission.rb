class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
  belongs_to :group
  has_one_attached :sub_file
end
