class AddColumnsToHurdyGurdyEnrollment < ActiveRecord::Migration[4.2]
  def change
    table = GrdaWarehouse::Hud::Enrollment.table_name

    add_column table, 'LOSUnderThreshold', :integer
    add_column table, 'PreviousStreetESSH', :integer
  end
end
