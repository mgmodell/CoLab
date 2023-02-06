class Rubric < ApplicationRecord
    belongs_to :parent, class_name: 'Rubric'
    has_many :versions, class_name: 'Rubric', foreign_key: 'parent_id'
    belongs_to :school
    belongs_to :user

    # Validations
    validates :passing, numericality: { in: 0..100 }

    before_create :set_owner

    def set_owner
        user ||= @current_user
        school ||= @current_user.school
    end

end
