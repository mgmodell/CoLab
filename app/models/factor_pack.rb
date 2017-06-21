# frozen_string_literal: true
class FactorPack < ActiveRecord::Base
  translates :name, :description
  has_and_belongs_to_many :factors, inverse_of: :factor_packs
  has_many :projects, inverse_of: :factor_pack
end
