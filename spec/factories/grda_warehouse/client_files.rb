FactoryBot.define do
  factory :client_file, class: 'GrdaWarehouse::ClientFile' do
    association :client, factory: :grda_warehouse_hud_client
    association :user, factory: :user
    file { 'file.jpg' }
    content_type { 'image/jpg' }
    content { 'TEST this must be more than 100 bytes or the validation will fail; TEST this must be more than 100 bytes or the validation will fail; TEST this must be more than 100 bytes or the validation will fail;' }
    name { 'Test File' }
    visible_in_window { true }
  end

  factory :client_file_coc_roi, class: 'GrdaWarehouse::ClientFile' do
    association :client, factory: :grda_warehouse_hud_client
    association :user, factory: :user
    file { 'file.jpg' }
    content_type { 'image/jpg' }
    content { 'TEST this must be more than 100 bytes or the validation will fail; TEST this must be more than 100 bytes or the validation will fail; TEST this must be more than 100 bytes or the validation will fail;' }
    name { 'CoC Roi' }
    visible_in_window { true }
  end
end
