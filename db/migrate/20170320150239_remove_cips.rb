# frozen_string_literal: true
class RemoveCips < ActiveRecord::Migration[4.2]
  def change
    drop_table :cips
  end
end
