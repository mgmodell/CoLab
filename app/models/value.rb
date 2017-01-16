class Value < ActiveRecord::Base
  belongs_to :user
  belongs_to :installment
end
