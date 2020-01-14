class CreateNightlyCensusByProjectClients < ActiveRecord::Migration[4.2]
  def change
    create_table :nightly_census_by_project_clients do |t|
      t.date :date, null: false
      t.integer :project_id, null: false

      [ 'veterans', 'non_veterans', 'children', 'adults', 'youth', 'families', 'individuals',
        'parenting_youth', 'parenting_juveniles', 'all_clients'].each do |count|
        t.jsonb count, default: []
      end

      t.timestamps null: false
    end
  end
end
