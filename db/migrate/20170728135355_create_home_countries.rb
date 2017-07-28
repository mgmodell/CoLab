class CreateHomeCountries < ActiveRecord::Migration
  def change
    create_table :home_countries do |t|
      t.string :name
      t.string :code

      t.timestamps null: false
    end
    add_index :home_countries, :code, unique: true
  end
end
