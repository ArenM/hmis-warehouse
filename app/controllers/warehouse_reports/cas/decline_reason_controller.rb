###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module WarehouseReports::Cas
  class DeclineReasonController < ApplicationController
    include WarehouseReportAuthorization
    before_action :set_range

    def index
      @matches = report_source.where.not( decline_reason: nil ).
        started_between(start_date: @range.start, end_date: @range.end + 1.day)
      @reasons = @matches.map do|row|
        row[:decline_reason].squish.gsub(/Other.*/,'Other').strip
      end.each_with_object(Hash.new(0)) { |reason,counts| counts[reason] += 1 }

      @all_steps = report_source.
        where(match_id: @matches.select(:match_id)).
        order(decision_order: :asc).
        group_by(&:match_id)

      @reasons.sort_by(&:last).reverse

      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def set_range
      date_range_options = params.permit(range: [:start, :end])[:range]
      unless date_range_options.present?
        date_range_options = {
          start: 13.month.ago.to_date,
          end: 1.months.ago.to_date,
        }
      end
      @range = ::Filters::DateRange.new(date_range_options)
    end

    def report_source
      GrdaWarehouse::CasReport
    end

  end
end
