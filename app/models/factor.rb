# frozen_string_literal: true
class Factor < ActiveRecord::Base
  has_and_belongs_to_many :factor_packs
end
