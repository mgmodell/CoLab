class AddImpairmentToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :impairment_visual, :boolean
    add_column :users, :impairment_auditory, :boolean
    add_column :users, :impairment_motor, :boolean
    add_column :users, :impairment_cognitive, :boolean
    add_column :users, :impairment_other, :boolean
  end
end
