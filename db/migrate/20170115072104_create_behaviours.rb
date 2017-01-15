class CreateBehaviours < ActiveRecord::Migration
  def change
    create_table :behaviours do |t|
      t.string :description
      t.string :name

      t.timestamps null: false
    end
  end
end
