# frozen_string_literal: true
class Factor < ActiveRecord::Base
  translates :name, :description
  belongs_to :factor_pack
end
