# frozen_string_literal: true
class AddI18nToFactor < ActiveRecord::Migration
  def change
    rename_column :factors, :name, :name_en
    add_column :factors, :name_ko, :string
    add_column :factors, :description_en, :string
    add_column :factors, :description_ko, :string

    add_index :factors, :name_en, unique: true
  end
end
