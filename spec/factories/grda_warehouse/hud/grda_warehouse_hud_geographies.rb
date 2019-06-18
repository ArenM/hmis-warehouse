FactoryBot.define do
  factory :grda_warehouse_hud_geography, class: 'GrdaWarehouse::Hud::Geography' do
    data_source_id { 1 } # :data_source_fixed_id
    DateCreated { Date.parse('2019-01-01') }
    DateUpdated { Date.parse('2019-01-01') }
  end
end
