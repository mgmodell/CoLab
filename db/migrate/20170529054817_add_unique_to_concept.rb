# frozen_string_literal: true
class AddUniqueToConcept < ActiveRecord::Migration[4.2]
  def change
    add_index :concepts, :name, unique: true
  end
end
