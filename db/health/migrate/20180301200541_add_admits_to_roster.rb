class AddAdmitsToRoster < ActiveRecord::Migration[4.2]
  def change
    add_column :claims_roster, :baseline_admits, :integer
    add_column :claims_roster, :implementation_admits, :integer
  end
end
