# frozen_string_literal: true
class AddThemeToUser < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :theme, index: true, foreign_key: true, default: 1
  end
end
