# frozen_string_literal: true
class AddLanguageToUser < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :language, index: true, foreign_key: true
  end
end
