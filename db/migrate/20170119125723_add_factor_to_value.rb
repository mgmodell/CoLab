# frozen_string_literal: true
class AddFactorToValue < ActiveRecord::Migration
  def change
    add_reference :values, :factor, index: true, foreign_key: true
  end
end
