class FactorPack < ActiveRecord::Base
  has_and_belongs_to_many :factors
  has_many :projects
end
