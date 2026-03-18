class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.datetime :submitted
      t.datetime :withdrawn
      t.float :recorded_score
      t.text :sub_text
      t.string :sub_link

      t.timestamps
    end
  end
end
