class CreateLanguage < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :code, unique: true
      t.string :name
    end
  end
end
