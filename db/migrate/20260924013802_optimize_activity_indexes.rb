class OptimizeActivityIndexes < ActiveRecord::Migration[8.1]
  def change
    # 1. Add the composite indexes FIRST so the Foreign Key constraints have a fallback index
    add_index :projects, [:course_id, :deleted, :end_date], name: 'idx_projects_timeline'
    add_index :bingo_games, [:course_id, :deleted, :end_date], name: 'idx_bingo_games_timeline'
    add_index :experiences, [:course_id, :deleted, :end_date], name: 'idx_experiences_timeline'
    add_index :assignments, [:course_id, :deleted, :end_date], name: 'idx_assignments_timeline'

    # 2. NOW it is safe to drop the redundant single-column indexes
    remove_index :projects, name: "index_projects_on_course_id" if index_exists?(:projects, name: "index_projects_on_course_id")
    remove_index :bingo_games, name: "index_bingo_games_on_course_id" if index_exists?(:bingo_games, name: "index_bingo_games_on_course_id")
    remove_index :experiences, name: "index_experiences_on_course_id" if index_exists?(:experiences, name: "index_experiences_on_course_id")
    remove_index :assignments, name: "index_assignments_on_course_id" if index_exists?(:assignments, name: "index_assignments_on_course_id")

    # 3. Optimize background cron jobs and active range lookups
    add_index :experiences, [:active, :start_date, :end_date], name: 'idx_exp_active_lookup'
    add_index :bingo_games, [:instructor_notified, :end_date], name: 'idx_bingo_cron_lookup'
    add_index :experiences, [:instructor_updated, :student_end_date], name: 'idx_exp_cron_lookup'

    # 4. User data lookup optimization (Add composite first, then remove redundant)
    add_index :candidate_lists, [:bingo_game_id, :user_id, :archived], name: 'idx_candidate_lists_lookup'
    remove_index :candidate_lists, name: "index_candidate_lists_on_bingo_game_id" if index_exists?(:candidate_lists, name: "index_candidate_lists_on_bingo_game_id")

    add_index :reactions, [:experience_id, :user_id], name: 'idx_reactions_lookup'
    remove_index :reactions, name: "index_reactions_on_experience_id" if index_exists?(:reactions, name: "index_reactions_on_experience_id")
  end
end
