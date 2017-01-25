class FactorPack < ActiveRecord::Base
  has_and_belongs_to_many :factors, inverse_of: :factor_packs
  has_many :projects, inverse_of: :factor_pack
end
