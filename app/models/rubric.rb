class Rubric < ApplicationRecord
    belongs_to :parent, class_name: 'Rubric'
    has_many :versions, class_name: 'Rubric', foreign_key: 'parent_id'

end
