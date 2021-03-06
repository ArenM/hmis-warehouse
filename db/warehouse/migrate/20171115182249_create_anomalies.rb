class CreateAnomalies < ActiveRecord::Migration[4.2]
  def change
    create_table :anomalies do |t|
      t.references :client, index: true
      t.integer :submitted_by
      t.string :description
      t.string :status, null: false, index: true
      t.timestamps
    end
  end
end
