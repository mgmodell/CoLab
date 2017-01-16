class CreateInstallments < ActiveRecord::Migration
  def change
    create_table :installments do |t|
      t.date :inst_date
      t.references :assessment, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.text :comments
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
