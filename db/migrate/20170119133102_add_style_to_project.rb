class AddStyleToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :style, index: true, foreign_key: true
  end
end
