# frozen_string_literal: true
class AddI18nToNarrative < ActiveRecord::Migration[4.2]
  def change
    rename_column :narratives, :member, :member_en
    add_column :narratives, :member_ko, :string

  end
end
