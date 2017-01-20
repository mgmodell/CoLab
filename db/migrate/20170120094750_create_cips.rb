class CreateCips < ActiveRecord::Migration
  def change
    create_table :cips do |t|
      t.integer :code
      t.string :description

      t.timestamps null: false
    end
  end
end
