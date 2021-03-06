class SetPilotPatientFlag < ActiveRecord::Migration[4.2][4.2]
  def up
    # Convert all current patients to pilot pattients
    add_column(:patients, :deleted_at, :datetime) unless column_exists? :patients, :deleted_at
  end

  def down
    remove_column :patients, :deleted_at
  end
end
