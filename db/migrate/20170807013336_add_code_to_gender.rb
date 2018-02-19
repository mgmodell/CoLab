class AddCodeToGender < ActiveRecord::Migration[4.2]
  def change
    add_column :genders, :code, :string
  end
end
