# frozen_string_literal: true

class Language < ApplicationRecord
  translates :name
  has_and_belongs_to_many :users
  has_many :home_users, inverse_of: :primary_language,
                        class_name: 'User', foreign_key: 'primary_language_id'

  default_scope { order('translated DESC', :code) }
  scope :supported, -> { where(translated: true) }
end
