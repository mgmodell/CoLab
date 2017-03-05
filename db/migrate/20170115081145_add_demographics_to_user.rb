# frozen_string_literal: true
class AddDemographicsToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_reference :users, :gender, index: true, foreign_key: true
    add_reference :users, :age_range, index: true, foreign_key: true
    add_column :users, :country, :string
    add_column :users, :timezone, :string
  end
end
