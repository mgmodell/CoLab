class AddAnonCommentsToInstallment < ActiveRecord::Migration[4.2]
  def change
    add_column :installments, :anon_comments, :text
  end
end
