class RubricRowFeedback < ApplicationRecord
  belongs_to :submissionFeedback
  belongs_to :criterium
end
