# frozen_string_literal: true
class AddResearcherToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :researcher, :boolean
  end
end
