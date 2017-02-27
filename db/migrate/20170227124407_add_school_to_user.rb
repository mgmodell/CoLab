class AddSchoolToUser < ActiveRecord::Migration
  def change
    add_reference :users, :school, index: true, foreign_key: true
  end
end
