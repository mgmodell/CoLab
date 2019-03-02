class AddI18nToCipCode < ActiveRecord::Migration[4.2]
  def change
    rename_column :cip_codes, :description, :name_en
    add_column :cip_codes, :name_ko, :string

    add_index :cip_codes, :gov_code, unique: true
  end
end
