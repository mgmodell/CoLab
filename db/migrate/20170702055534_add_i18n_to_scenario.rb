# frozen_string_literal: true
class AddI18nToScenario < ActiveRecord::Migration
  def change
    rename_column :scenarios, :name, :name_en
    add_column :scenarios, :name_ko, :string

  end
end
