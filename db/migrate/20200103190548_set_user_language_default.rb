class SetUserLanguageDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :language_id, 40
    change_column_null :users, :language_id, false, 40
  end
end
