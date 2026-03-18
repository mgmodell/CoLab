class AddCountOfDiagnosesToReactions < ActiveRecord::Migration[7.0]
  def change
    add_column :reactions, :diagnoses_count, :integer
  end
end
