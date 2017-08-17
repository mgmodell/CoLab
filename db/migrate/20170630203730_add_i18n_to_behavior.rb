# frozen_string_literal: true
class AddI18nToBehavior < ActiveRecord::Migration
  def change
    rename_column :behaviors, :name, :name_en
    add_column :behaviors, :name_ko, :string
    change_column :behaviors, :description, :text
    rename_column :behaviors, :description, :description_en
    add_column :behaviors, :description_ko, :string

    add_index :behaviors, :name_en, unique: true
  end
end
