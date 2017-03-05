# frozen_string_literal: true
class Gender < ActiveRecord::Base
  has_many :users, inverse_of: :gender
end
