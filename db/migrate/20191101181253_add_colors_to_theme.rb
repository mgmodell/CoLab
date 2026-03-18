class AddColorsToTheme < ActiveRecord::Migration[6.0]
  def change
    add_column :themes, :primary, :string
    add_column :themes, :secondary, :string
  end
end
