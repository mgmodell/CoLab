class Assignment < ApplicationRecord
    include DateSanitySupportConcern,
            TimezonesSupportConcern

    belongs_to :rubric
    belongs_to :course
    belongs_to :project, optional: true

    # Validations
    validates :passing, numericality: { in: 0..100 }
end
