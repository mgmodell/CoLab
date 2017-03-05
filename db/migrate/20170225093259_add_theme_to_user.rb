# frozen_string_literal: true
class AddThemeToUser < ActiveRecord::Migration
  def change
    add_reference :users, :theme, index: true, foreign_key: true, default: 1
  end
end
