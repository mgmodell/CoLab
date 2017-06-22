class DropFactorPackToFactor < ActiveRecord::Migration
  def change
    drop_join_table :factor_packs, :factors
  end
end
