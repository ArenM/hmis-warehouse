class CreateUserAgency < ActiveRecord::Migration[4.2]
  def change
    create_table :agency_users do |t|
      t.integer :agency_id, null: false
      t.integer :user_id, null: false
    end
  end
end
