# frozen_string_literal: true
class AddFactorPackToFactor < ActiveRecord::Migration
  def change
    add_reference :factors, :factor_pack, index: true, foreign_key: true
  end
end
