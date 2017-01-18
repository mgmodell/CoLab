class AddBehaviourPackToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :behaviour_pack, index: true, foreign_key: true
  end
end
