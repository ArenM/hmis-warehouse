class CreateTableWhitelistedProjectsForClients < ActiveRecord::Migration[4.2]
  def change
    create_table :whitelisted_projects_for_clients do |t|
      t.references :data_source, null: false
      t.string :ProjectID, null: false
      t.timestamps
    end
  end
end
