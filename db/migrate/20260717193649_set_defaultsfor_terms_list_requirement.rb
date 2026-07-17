class SetDefaultsforTermsListRequirement < ActiveRecord::Migration[8.1]
  def change
    change_column_default :bingo_games, :individual_count, from: nil, to: 10
  end
end
