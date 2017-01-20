class CreateCips < ActiveRecord::Migration
  def change
    create_table :cips, :id => false do |t|
      t.integer :id, :options => 'PRIMARY KEY'
      t.string :description

      t.timestamps null: false
    end
  end
end
