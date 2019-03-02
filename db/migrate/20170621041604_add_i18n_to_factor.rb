# frozen_string_literal: true
class AddI18nToFactor < ActiveRecord::Migration[4.2]
  def change
    rename_column :factors, :name, :name_en
    add_column :factors, :name_ko, :string
    rename_column :factors, :description, :description_en
    add_column :factors, :description_ko, :string

    add_index :factors, :name_en, unique: true
  end
end
