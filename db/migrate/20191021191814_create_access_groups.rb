class CreateAccessGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :access_groups do |t|
      t.string :name
      t.references :user, null: true
      t.string :coc_codes, array: true, default: []

      t.datetime :deleted_at
    end
  end
end
