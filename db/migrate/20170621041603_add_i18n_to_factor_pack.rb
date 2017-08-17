# frozen_string_literal: true
class AddI18nToFactorPack < ActiveRecord::Migration
  def change
    rename_column :factor_packs, :name, :name_en
    add_column :factor_packs, :name_ko, :string
    rename_column :factor_packs, :description, :description_en
    add_column :factor_packs, :description_ko, :string

    add_index :factor_packs, :name_en, unique: true
  end
end
