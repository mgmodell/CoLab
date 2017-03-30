# frozen_string_literal: true
class RemoveCips < ActiveRecord::Migration
  def change
    drop_table :cips
  end
end
