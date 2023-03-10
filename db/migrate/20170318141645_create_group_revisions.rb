# frozen_string_literal: true
class CreateGroupRevisions < ActiveRecord::Migration[4.2]
  def change
    create_table :group_revisions do |t|
      t.references :group, index: true, foreign_key: true
      t.string :name
      t.string :members

      t.timestamps null: false
    end
  end
end
