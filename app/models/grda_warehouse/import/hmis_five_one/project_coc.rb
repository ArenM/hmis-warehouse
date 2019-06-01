###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module GrdaWarehouse::Import::HMISFiveOne
  class ProjectCoc < GrdaWarehouse::Hud::ProjectCoc
    include ::Import::HMISFiveOne::Shared
    include TsqlImport

    setup_hud_column_access( GrdaWarehouse::Hud::ProjectCoc.hud_csv_headers(version: '5.1') )

    self.hud_key = :ProjectCoCID

    def self.file_name
      'ProjectCoC.csv'
    end
  end
end