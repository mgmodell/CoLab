class CreateFactors < ActiveRecord::Migration
  def change
    create_table :factors do |t|
      t.string :description
      t.string :name

      t.timestamps null: false
    end
  end
end
