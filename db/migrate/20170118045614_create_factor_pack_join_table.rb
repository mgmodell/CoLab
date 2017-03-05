# frozen_string_literal: true
class CreateFactorPackJoinTable < ActiveRecord::Migration
  def change
    create_join_table :factors, :factor_packs do |t|
      # t.index [:factor_id, :factor_pack_id]
      # t.index [:factor_pack_id, :factor_id]
    end
  end
end
