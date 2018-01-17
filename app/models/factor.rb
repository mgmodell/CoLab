# frozen_string_literal: true

class Factor < ApplicationRecord
  translates :name, :description
  belongs_to :factor_pack
end
