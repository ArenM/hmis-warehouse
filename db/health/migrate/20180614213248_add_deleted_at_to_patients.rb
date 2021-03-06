class AddDeletedAtToPatients < ActiveRecord::Migration[4.2][4.2]
  def up
    unless column_exists? :patients, :deleted_at
      add_column :patients, :deleted_at, :datetime
    end
  end
  def down
    if column_exists? :patients, :deleted_at
      remove_column :patients, :deleted_at, :datetime
    end
  end
end
