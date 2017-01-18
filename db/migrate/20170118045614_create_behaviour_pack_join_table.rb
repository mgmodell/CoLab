class CreateBehaviourPackJoinTable < ActiveRecord::Migration
  def change
    create_join_table :behaviours, :behaviour_packs do |t|
      # t.index [:behaviour_id, :behaviour_pack_id]
      # t.index [:behaviour_pack_id, :behaviour_id]
    end
  end
end
