class AddCacheCountersForOptimizations < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_lists, :candidates_count,
               :integer, default: 0, null: false
  end
end
