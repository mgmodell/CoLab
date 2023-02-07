class Assignment < ApplicationRecord
    include DateSanitySupportConcern,
            TimezonesSupportConcern

  belongs_to :rubric
  belongs_to :course
  belongs_to :project, optional: true
end
