###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module WarehouseReports
  class HmisSixOneOneExportJob < BaseJob
    include ArelHelper

    queue_as :hmis_six_one_one_export

    def perform options, report_url: warehouse_reports_hmis_exports_url
      options = options.with_indifferent_access
      report = Exporters::HmisSixOneOne::Base.new(
        start_date: options[:start_date],
        end_date: options[:end_date],
        projects: options[:projects],
        period_type: options[:period_type],
        directive: options[:directive],
        hash_status: options[:hash_status],
        include_deleted: options[:include_deleted],
        faked_pii: options[:faked_pii],
        user_id: options[:user_id]
      ).export!

      if recurring_hmis_export = recurring_hmis_export(options)
        GrdaWarehouse::RecurringHmisExportLink.create(hmis_export_id: report.id, recurring_hmis_export_id: recurring_hmis_export.id, exported_at: Date.today)
        if recurring_hmis_export.s3_valid?
          recurring_hmis_export.store(report)
        end
      end

      if report_url.present?
        NotifyUser.hmis_export_finished(options[:user_id], report.id, report_url: report_url).deliver_later
      end
    end

    def log msg, underline: false
      return unless Rails.env.development?
      Rails.logger.info msg
      Rails.logger.info "="*msg.length if underline
    end

    def recurring_hmis_export(options)
      recurring_hmis_export = options[:recurring_hmis_export_id]
      return nil if  recurring_hmis_export == 0
      GrdaWarehouse::RecurringHmisExport.find(recurring_hmis_export)
    end
  end
end