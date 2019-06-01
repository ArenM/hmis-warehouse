###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module GrdaWarehouse::Import::HMISFiveOne
  class Service < GrdaWarehouse::Hud::Service
    include ::Import::HMISFiveOne::Shared
    include TsqlImport

    setup_hud_column_access( GrdaWarehouse::Hud::Service.hud_csv_headers(version: '5.1') )

    self.hud_key = :ServicesID
    def self.date_provided_column
      :DateProvided
    end

    def self.file_name
      'Services.csv'
    end
  end
end