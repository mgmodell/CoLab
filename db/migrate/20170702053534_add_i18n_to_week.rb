# frozen_string_literal: true
class AddI18nToWeek < ActiveRecord::Migration
  def change
    rename_column :weeks, :text, :text_en
    add_column :weeks, :text_ko, :text

    add_index :weeks, [:week_num, :narrative_id], unique: true
  end
end
