# frozen_string_literal: true
class AddUniqueToConcept < ActiveRecord::Migration
  def change
    add_index :concepts, :name, unique: true
  end
end
