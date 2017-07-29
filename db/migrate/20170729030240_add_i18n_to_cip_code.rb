class AddI18nToCipCode < ActiveRecord::Migration
  def change
    rename_column :cip_codes, :description, :description_en
    add_column :cip_codes, :description_ko, :string

    add_index :cip_codes, :gov_code, unique: true
  end
end
