# frozen_string_literal: true
class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.references :user, index: true, foreign_key: true
      t.string :email
      t.boolean :primary, default: false
      t.string :confirmation_token
      t.string :unconfirmed_email
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps null: false
    end
  end
end
