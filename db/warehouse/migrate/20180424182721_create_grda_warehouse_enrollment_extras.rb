class CreateGrdaWarehouseEnrollmentExtras < ActiveRecord::Migration[4.2]
  def change
    create_table :enrollment_extras do |t|
      t.references :enrollment, null: false, delete: :cascade
      t.integer    :vispdat_grand_total
      t.date       :vispdat_added_at
      t.date       :vispdat_started_at
      t.date       :vispdat_ended_at
      t.string     :source_tab
      t.timestamps
    end
  end
end
