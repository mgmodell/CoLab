class AddAnonCommentsToInstallment < ActiveRecord::Migration
  def change
    add_column :installments, :anon_comments, :text
  end
end
