# frozen_string_literal: true
class AddFactorPackToProject < ActiveRecord::Migration[4.2]
  def change
    add_reference :projects, :factor_pack, index: true, foreign_key: true
  end
end
