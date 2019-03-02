class CreateHomeCountries < ActiveRecord::Migration[4.2]
  def change
    create_table :home_countries do |t|
      t.string :name
      t.string :code
      t.boolean :no_response

      t.timestamps null: false
    end
    add_index :home_countries, :code, unique: true
  end
end
