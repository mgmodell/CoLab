# frozen_string_literal: true

class Value < ApplicationRecord
  belongs_to :user
  belongs_to :installment, inverse_of: :values
  belongs_to :factor
end
