# frozen_string_literal: true
class CreateLanguage < ActiveRecord::Migration[4.2]
  def change
    create_table :languages do |t|
      t.string :code, unique: true
      t.string :name
    end
  end
end
