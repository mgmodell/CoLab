# frozen_string_literal: true
class AddI18nToTheme < ActiveRecord::Migration[4.2]
  def change
    rename_column :themes, :name, :name_en
    add_column :themes, :name_ko, :string

    add_index :themes, :name_en, unique: true
    add_index :themes, :code, unique: true
  end
end
