class CandidateList < ActiveRecord::Base
  belongs_to :user, inverse_of: :candidate_lists
  belongs_to :group, inverse_of: :candidate_lists
  has_many :candidates, inverse_of: :candidate_list, dependent: :destroy
end
