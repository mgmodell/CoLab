class AddSubmissionTypesToAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :file_sub, :boolean,
      null: false, default: false
    add_column :assignments, :link_sub, :boolean,
      null: false, default: false
    add_column :assignments, :text_sub, :boolean,
      null: false, default: true
  end
end
