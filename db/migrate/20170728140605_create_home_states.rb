class CreateHomeStates < ActiveRecord::Migration
  def change
    create_table :home_states do |t|
      t.references :home_country, index: true, foreign_key: true
      t.string :name
      t.string :code

      t.timestamps null: false
    end
    add_index :home_states, [:home_country_id, :name], unique: true
  end
end
