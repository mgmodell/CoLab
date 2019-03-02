class DropAgeRange < ActiveRecord::Migration[4.2]
  def change
    drop_table :age_ranges
  end
end
