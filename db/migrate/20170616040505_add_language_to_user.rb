# frozen_string_literal: true
class AddLanguageToUser < ActiveRecord::Migration
  def change
    add_reference :users, :language, index: true, foreign_key: true
  end
end
