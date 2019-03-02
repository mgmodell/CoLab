# frozen_string_literal: true
class AddI18nToAgeRange < ActiveRecord::Migration[4.2]
  def change
    rename_column :age_ranges, :name, :name_en
    add_column :age_ranges, :name_ko, :string

    add_index :age_ranges, :name_en, unique: true
  end
end
