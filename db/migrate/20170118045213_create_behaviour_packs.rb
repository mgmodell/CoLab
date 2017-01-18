class CreateBehaviourPacks < ActiveRecord::Migration
  def change
    create_table :behaviour_packs do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
