module GrdaWarehouse::WarehouseReports::Project::DataQuality
  class VersionFour < Base

    has_many :enrollments, class_name: Reporting::DataQualityReports::Enrollment.name

    def run!
      progress_methods = [
        :start_report,
        :build_report_enrollments,
        :set_inventory_details,
        :finish_report,
      ]
      progress_methods.each_with_index do |method, i|
        percent = ((i/progress_methods.size.to_f)* 100)
        percent = 0.01 if percent == 0
        Rails.logger.info "Starting #{method}, #{percent.round(2)}% complete"
        self.send(method)
        Rails.logger.info "Completed #{method}"
      end
    end

    def report_range
      @report_range ||= ::Filters::DateRange.new(start: @start_date, end: @end_date)
    end

    def report_start
      self.start.to_date
    end

    def report_end
      self.end.to_date
    end

    def build_report_enrollments
      @report_enrollments = []
      source_enrollments.each do |hud_en|
        report_enrollment = enrollments.build(
          client_id: hud_en.client.id,
          project_id: hud_en.project.id,
          enrollment_id: hud_en.id,
          enrolled: true,

        )
        report_enrollment = set_calculated_fields(hud_enrollment: hud_en, report_enrollment: report_enrollment)
      end
    end

    def set_calculated_fields hud_enrollment:, report_enrollment:
      report_enrollment.head_of_household = is_head_of_household?(hud_en)
    end

    def set_inventory_details

    end

    # NOTE: since this is a report that is looking specifically at HMIS data quality
    # we are sticking to source data, including source clients
    def source_enrollments
      @source_enrollments ||= GrdaWarehouse::Hud::Enrollment.open_during_range(report_range).
        joins(:project).
        preload(:exit, :client, :project).
        merge(GrdaWarehouse::Hud::Project.where(id: projects.map(&:id)))
    end

    def leavers
      @leavers ||= source_enrollments.joins(:exit).
        where(ExitDate: (report_start..report_end))
    end

    # enrollments with joined/preloaded exits, keyed on enrollment id
    def leavers_by_enrollment_id
      @leavers_by_enrollment_id ||= leavers.index_by(&:id)
    end

    def exit_for_enrollment_id id
      leavers_by_enrollment_id[id].exit
    end

    def stayers
      @stayers ||= source_enrollments.where.not(id: @leavers.select(:id))
    end


  end
end