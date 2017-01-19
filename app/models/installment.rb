class Installment < ActiveRecord::Base
  belongs_to :assessment, :inverse_of => :installments
  belongs_to :user, :inverse_of => :installments
  belongs_to :group, :inverse_of => :installments

  has_many :values, :inverse_of => :installment

end
