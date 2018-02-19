# frozen_string_literal: true
class AddI18nToGender < ActiveRecord::Migration[4.2]
  def change
    rename_column :genders, :name, :name_en
    add_column :genders, :name_ko, :string

    add_index :genders, :name_en, unique: true
  end
end
