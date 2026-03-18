class AddAnonOffsetToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :anon_offset, :integer, null: false, default: 0
  end
end
