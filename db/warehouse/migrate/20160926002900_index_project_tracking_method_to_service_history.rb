class IndexProjectTrackingMethodToServiceHistory < ActiveRecord::Migration[4.2]
  def change
    add_index :warehouse_client_service_history, :project_tracking_method, name: :index_sh_tracking_method
  end
end
