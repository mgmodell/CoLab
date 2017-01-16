class Installment < ActiveRecord::Base
  belongs_to :assessment
  belongs_to :user
  belongs_to :group
end
