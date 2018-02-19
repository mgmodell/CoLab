# frozen_string_literal: true
class AddI18nToStyle < ActiveRecord::Migration[4.2]
  def change
    rename_column :styles, :name, :name_en
    add_column :styles, :name_ko, :string

    add_index :styles, :name_en, unique: true
  end
end
