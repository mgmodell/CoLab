# frozen_string_literal: true

# This migration comes from keypairs (originally 20201024100500)
class CreateKeypairs < ActiveRecord::Migration[6.0]
  def change
    create_table :keypairs do |t|
      t.string :jwk_kid, null: false
      t.text :_keypair_ciphertext, null: false
      t.timestamps precision: 6
      # Since we are ordering on created_at, let's create an index
      t.index :created_at
      t.index :jwk_kid, unique: true
    end
  end
end
