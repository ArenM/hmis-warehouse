class AddCasAdditionalFlags < ActiveRecord::Migration[4.2]
  def change
    [
      :chronically_homeless_for_cas,
      :us_citizen,
      :assylee,
      :ineligible_immigrant,
      :lifetime_sex_offender,
      :meth_production_conviction,
      :family_member,
      :child_in_household,
    ].each do |column|
      add_column :Client, column, :boolean, default: false, null: false
    end 
  end
end
