# frozen_string_literal: true

# This migration comes from keypairs (originally 20201116144600)
class AddValidityToKeypairs < ActiveRecord::Migration[6.0]
  class Keypair < ActiveRecord::Base; end

  def change # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    change_table :keypairs, bulk: true do |t|
      t.datetime :not_before, precision: 6
      t.datetime :not_after, precision: 6
      t.datetime :expires_at, precision: 6
    end

    reversible do |dir|
      dir.up do
        Keypair.find_each do |keypair|
          keypair.update!(
            not_before: keypair.created_at,
            not_after: keypair.created_at + 1.month,
            expires_at: keypair.created_at + 2.months
          )
        end
      end
    end

    change_column_null :keypairs, :not_before, false
    change_column_null :keypairs, :not_after, false
    change_column_null :keypairs, :expires_at, false
  end
end
