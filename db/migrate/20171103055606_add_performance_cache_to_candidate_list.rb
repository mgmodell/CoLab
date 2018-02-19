class AddPerformanceCacheToCandidateList < ActiveRecord::Migration[4.2]
  def change
    add_column :candidate_lists, :cached_performance, :integer
  end
end
