class AddTranslatedToLanguage < ActiveRecord::Migration[4.2]
  def change
    add_column :languages, :translated, :boolean
  end
end
