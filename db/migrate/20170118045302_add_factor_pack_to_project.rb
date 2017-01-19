class AddFactorPackToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :factor_pack, index: true, foreign_key: true
  end
end
