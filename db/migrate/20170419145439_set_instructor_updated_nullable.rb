# frozen_string_literal: true
class SetInstructorUpdatedNullable < ActiveRecord::Migration
  def change
    change_column_default :assessments, :instructor_updated, false
    change_column_null :assessments, :instructor_updated, false
    change_column_default :experiences, :instructor_updated, false
    change_column_null :experiences, :instructor_updated, false
  end
end
