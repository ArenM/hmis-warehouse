module WarehouseReports
  class DobEntrySameController < WarehouseReportsController
    include WarehouseReportAuthorization
    def index
      et = GrdaWarehouse::Hud::Enrollment.arel_table
      @clients = client_source.distinct
        .joins(:source_enrollments)
        .preload(:source_enrollments)
        .where( client_source.arel_table[:DOB].eq et[:EntryDate] ) #'Client.DOB = EntryDate')
        .where.not(DOB: nil)
        .order(DOB: :asc)
        .page(params[:page]).per(25)
    end

    def related_report
      GrdaWarehouse::WarehouseReports::ReportDefinition.where(url: 'warehouse_reports/dob_entry_same')
    end

    private def client_source
      GrdaWarehouse::Hud::Client.destination
    end

    private def enrollment_source
      GrdaWarehouse::Hud::Enrollment
    end

    private def data_source_source
      GrdaWarehouse::DataSource
    end

  end
end
