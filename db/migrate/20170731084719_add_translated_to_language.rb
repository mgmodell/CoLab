class AddTranslatedToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :translated, :boolean
  end
end
