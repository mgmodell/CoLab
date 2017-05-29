class AddUniqueToConcept < ActiveRecord::Migration
  def change
    add_index :concepts, :name, :unique => true
  end
end
