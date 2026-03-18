# frozen_string_literal: true

class FactorPack < ApplicationRecord
  translates :name, :description
  has_many :factors, inverse_of: :factor_pack, dependent: :destroy
  has_many :projects, inverse_of: :factor_pack, dependent: :nullify
end
