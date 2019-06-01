###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module WarehouseReports
  class InitiativeReportJob < BaseJob
    include ArelHelper

    queue_as :initiative_reports

    def perform options
      options = options.with_indifferent_access
      report = GrdaWarehouse::WarehouseReports::InitiativeReport.new(parameters: options, user_id: options[:user_id]).run!
      # NotifyUser.hmis_export_finished(options[:user_id], report.id).deliver_later
    end

    def log msg, underline: false
      return unless Rails.env.development?
      Rails.logger.info msg
      Rails.logger.info "="*msg.length if underline
    end

  end
end