# frozen_string_literal: true
class AddI18nToRole < ActiveRecord::Migration[4.2]
  def change
    rename_column :roles, :name, :name_en
    add_column :roles, :name_ko, :string
    add_column :roles, :code, :string
    rename_column :roles, :description, :description_en
    add_column :roles, :description_ko, :string

    add_index :roles, :name_en, unique: true
    add_index :roles, :code, unique: true
  end
end
