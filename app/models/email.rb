# frozen_string_literal: true

class Email < ApplicationRecord
  belongs_to :user, inverse_of: :emails

end
