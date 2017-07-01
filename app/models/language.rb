# frozen_string_literal: true
class Language < ActiveRecord::Base
  translates :name
  default_scope { order(:code) }
  has_and_belongs_to_many :users
end
