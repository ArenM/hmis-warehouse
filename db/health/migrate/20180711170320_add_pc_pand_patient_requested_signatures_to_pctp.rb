class AddPcPandPatientRequestedSignaturesToPctp < ActiveRecord::Migration[4.2]
  def change
    add_column :careplans, :patient_signature_requested_at, :datetime
    add_column :careplans, :provider_signature_requested_at, :datetime
  end
end
