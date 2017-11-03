class AddPerformanceCacheToCandidateList < ActiveRecord::Migration
  def change
    add_column :candidate_lists, :cached_performance, :integer
  end
end
