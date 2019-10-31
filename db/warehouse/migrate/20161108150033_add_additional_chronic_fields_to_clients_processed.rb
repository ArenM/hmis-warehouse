class AddAdditionalChronicFieldsToClientsProcessed < ActiveRecord::Migration[4.2]
  def change
    add_column :warehouse_clients_processed, :days_homeless_last_three_years, :integer
    add_column :warehouse_clients_processed, :months_homeless_last_three_years, :integer
  end
end
