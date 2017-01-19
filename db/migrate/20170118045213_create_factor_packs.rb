class CreateFactorPacks < ActiveRecord::Migration
  def change
    create_table :factor_packs do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
