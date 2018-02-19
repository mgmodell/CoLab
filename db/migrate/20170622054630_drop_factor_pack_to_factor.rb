# frozen_string_literal: true
class DropFactorPackToFactor < ActiveRecord::Migration[4.2]
  def change
    drop_join_table :factor_packs, :factors
  end
end
