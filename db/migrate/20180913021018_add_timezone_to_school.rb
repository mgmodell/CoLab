class AddTimezoneToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :timezone, :string, null: false, default: 'UTC'

  end
end
