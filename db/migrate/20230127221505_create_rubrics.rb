class CreateRubrics < ActiveRecord::Migration[7.0]
  def change
    create_table :rubrics do |t|
      t.string :name, null: false
      t.text :description
      t.integer :passing, null: false, default: 65
      t.integer :version, null: false, default: 1
      t.boolean :published, null: false, default: false
      t.references :parent, null: true, foreign_key: {to_table: :rubrics}

      t.timestamps

    end
  end
end
