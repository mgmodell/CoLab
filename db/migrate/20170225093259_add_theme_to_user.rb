class AddThemeToUser < ActiveRecord::Migration
  def change
    add_reference :users, :theme, index: true, foreign_key: true
  end
end
