# frozen_string_literal: true

class Value < ApplicationRecord
  belongs_to :user
  delegate :name, to: :user, prefix: true

  belongs_to :installment, inverse_of: :values
  delegate :group_id, :group, :user_id, :user, :inst_date,
           :assessment_id, :assessment,
           to: :installment, prefix: true

  belongs_to :factor
  delegate :name, to: :factor, prefix: true
end
