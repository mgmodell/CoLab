class AddCandidateToBingoCell < ActiveRecord::Migration[5.2]
  def change
    add_column :bingo_cells, :indeks, :integer, null: true
    add_reference :bingo_cells, :candidate, type: :integer,
                foreign_key: true, null: true
  end
end
