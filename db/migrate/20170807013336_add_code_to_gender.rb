class AddCodeToGender < ActiveRecord::Migration
  def change
    add_column :genders, :code, :string
  end
end
