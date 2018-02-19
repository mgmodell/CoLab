# frozen_string_literal: true
class AddI18nToLanguage < ActiveRecord::Migration[4.2]
  def change
    rename_column :languages, :name, :name_en
    add_column :languages, :name_ko, :string

    add_index :languages, :code, unique: true
    add_index :languages, :name_en, unique: true
  end
end
