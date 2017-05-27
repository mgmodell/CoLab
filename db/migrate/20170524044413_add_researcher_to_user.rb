# frozen_string_literal: true
class AddResearcherToUser < ActiveRecord::Migration
  def change
    add_column :users, :researcher, :boolean
  end
end
