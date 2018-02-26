class ChangeDescriptionStringsToText < ActiveRecord::Migration[5.1]
  def change
    change_column :behaviors, :description_ko, :text
    change_column :courses, :description, :text
    change_column :schools, :description, :text
    change_column :projects, :description, :text
    change_column :projects, :description, :text

    change_column :factor_packs, :description_ko, :text
    change_column :factors, :description_ko, :text
    change_column :factors, :description_en, :text

  end
end
