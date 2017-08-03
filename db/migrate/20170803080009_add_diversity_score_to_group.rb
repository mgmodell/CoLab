class AddDiversityScoreToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :diversity_score, :integer
  end
end
