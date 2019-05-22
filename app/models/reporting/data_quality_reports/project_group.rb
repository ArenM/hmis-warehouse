module Reporting::DataQualityReports
  class ProjectGroup < ReportingBase
    include ArelHelper

    self.table_name = :warehouse_data_quality_report_project_groups

    belongs_to :report, class_name: GrdaWarehouse::WarehouseReports::Project::DataQuality::Base.name, foreign_key: :report_id

    def calculate_unit_inventory project_ids:, report_range:
      GrdaWarehouse::Hud::Project.where(id: project_ids).joins(:inventories).
        merge(GrdaWarehouse::Hud::Inventory.within_range(report_range)).
          map do |m|
          m[:UnitInventory] || 0
        end.sum
    end

    def calculate_bed_inventory project_ids:, report_range:
      GrdaWarehouse::Hud::Project.where(id: project_ids).joins(:inventories).
        merge(GrdaWarehouse::Hud::Inventory.within_range(report_range)).
          map do |m|
          m[:BedInventory] || 0
        end.sum
    end

    # NOTE: this relies on service_history_service, not source data
    # Because we'll need to de-dupe these for the project group, we can't rely on the DB
    # to do the counting, we'll store client ids per date
    def calculate_nightly_client_census project_ids:, report_range:
      services_scope(project_ids: project_ids, report_range: report_range).
        group(:date).select(:client_id).distinct.count
    end

    # NOTE: this relies on service_history_service, not source data
    # Counts unique client_ids only for heads of household
    # Because we'll need to de-dupe these for the project group, we can't rely on the DB
    # to do the counting, we'll store client ids per date
    def calculate_nightly_household_census project_ids:, report_range:
      services_scope(project_ids: project_ids, report_range: report_range).
        merge(GrdaWarehouse::ServiceHistoryEnrollment.heads_of_households).
        group(:date).select(:client_id).distinct.count
    end

    def services_scope project_ids:, report_range:
      GrdaWarehouse::ServiceHistoryService.joins(service_history_enrollment: :project).
        merge(GrdaWarehouse::Hud::Project.where(id: project_ids)).
        where(date: report_range.range)
    end

    # these rely on previously calculated values
    def calculate_average_nightly_clients report_range:
      ((self.nightly_client_census.values.sum.to_f / report_range.range.count) * 100).round rescue 0
    end

    def calculate_average_nightly_households report_range:
      ((self.nightly_household_census.values.sum.to_f / report_range.range.count) * 100).round rescue 0
    end

    def calculate_average_bed_utilization
      ((self.bed_inventory.to_f / self.average_nightly_clients) * 100).round rescue 0
    end

    def calculate_average_unit_utilization
      ((self.unit_inventory.to_f / self.average_nightly_households) * 100).round rescue 0
    end

  end
end