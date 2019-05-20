class RemovePaperClip < ActiveRecord::Migration[5.2]
  def change
    remove_attachment :consent_forms, :pdf
  end
end
