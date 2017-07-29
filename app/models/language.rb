# frozen_string_literal: true
class Language < ActiveRecord::Base
  translates :name
  default_scope { order(:code) }
  has_and_belongs_to_many :users
  has_many :home_users, inverse_of: :primary_language,
            class_name: 'User', foreign_key: 'primary_language_id'
end
