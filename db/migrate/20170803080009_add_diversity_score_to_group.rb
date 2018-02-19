class AddDiversityScoreToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :diversity_score, :integer
  end
end
