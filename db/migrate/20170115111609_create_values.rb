class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.integer :value
      t.references :user, index: true, foreign_key: true
      t.references :installment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
