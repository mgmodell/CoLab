class AddNeedsDetailToBehavior < ActiveRecord::Migration[6.0]
  def change
    add_column :behaviors, :needs_detail, :boolean, null: false, default: false
  end
end
