# frozen_string_literal: true
class Theme < ActiveRecord::Base
  has_many :users, inverse_of: :theme
end
