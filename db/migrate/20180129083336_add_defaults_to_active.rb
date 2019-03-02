class AddDefaultsToActive < ActiveRecord::Migration[4.2]
  def change
    change_column_default( :bingo_games, :active, 0 )
    change_column_null( :bingo_games, :active, true )
    change_column_default( :experiences, :active, 0 )
    change_column_null( :experiences, :active, true )
    change_column_default( :projects, :active, 0 )
    change_column_null( :projects, :active, true )
  end
end
