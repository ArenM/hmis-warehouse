###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

# This version of the AHAR report is scoped to a particular project at a particular data source
module ReportGenerators::Ahar::Fy2017
  class ByProject < Base
    def report_class
      Reports::Ahar::Fy2017::ByProject
    end

    private def involved_entries_scope
      super.where(Project: {id: @project_id})
    end
  end
end