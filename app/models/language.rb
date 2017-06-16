# frozen_string_literal: true
class Language < ActiveRecord::Base
  default_scope { order(:name) }
  has_and_belongs_to_many :users
end
