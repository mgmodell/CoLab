# frozen_string_literal: true
class AddLastEmailedToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_emailed, :datetime
  end
end
