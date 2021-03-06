###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

# A reporting table to power the population dash boards.
# One row per client per sub-population per month.

module Reporting::MonthlyReports
  class Base < ReportingBase
    include ArelHelper
    include ::Reporting::MonthlyReports::MonthlyReportCharts

    self.table_name = :warehouse_partitioned_monthly_reports

    LOOKBACK_START = '2014-07-01'

    after_initialize :set_dates
    attr_accessor :date_range

    def self.available_types
      {
        all_clients: Reporting::MonthlyReports::AllClients,
        veteran: Reporting::MonthlyReports::Veteran,
        youth: Reporting::MonthlyReports::Youth,
        parenting_youth: Reporting::MonthlyReports::ParentingYouth,
        parenting_children: Reporting::MonthlyReports::ParentingChildren,
        unaccompanied_minors: Reporting::MonthlyReports::UnaccompaniedMinors,
        individual_adults: Reporting::MonthlyReports::IndividualAdults,
        non_veteran: Reporting::MonthlyReports::NonVeteran,
        family: Reporting::MonthlyReports::Family,
        children: Reporting::MonthlyReports::Children,
      }
    end

    def self.class_for sub_population
      available_types[sub_population.to_sym]
    end

    def set_dates
      @date_range ||= LOOKBACK_START.to_date..Date.yesterday
      @start_date = @date_range.first
      @end_date = @date_range.last
    end

    def populate!
      populate_used_client_ids
      remove_unused_client_ids
      Reporting::MonthlyClientIds.where(report_type: self.class.name).
        distinct.
        pluck_in_batches(:client_id, batch_size: 5_000) do |batch|
          batch = batch.flatten
          set_enrollments_by_client batch
          set_prior_enrollments
          self.class.transaction do
            _clear!(batch)
            self.class.import @enrollments_by_client.values.flatten
          end
        end
      maintain_month_range_cache
    end

    private def maintain_month_range_cache
      Rails.cache.delete([self.class.name, 'month-range'])
      self.class.available_months
    end

    def self.available_months
      Rails.cache.fetch([self.name, 'month-range'], expires_in: 24.hours) do
        distinct.
        order(year: :desc, month: :desc).
        pluck(:year, :month).map do |year, month|
          date = Date.new(year, month, 1)
          [[year, month], date.strftime('%B %Y')]
        end.to_h
      end
    end

    # NOTE: we can't truncate or clear all because we load the table in batches
    # in transactions.  If we truncated we'd have a state where only some of the
    # data was available
    def _clear! ids
      self.class.where(client_id: ids).delete_all
    end

    def remove_unused_client_ids
      self.class.where.not(client_id:
        Reporting::MonthlyClientIds.where(report_type: self.class.name).
          distinct.select(:client_id)
      ).delete_all
    end

    def populate_used_client_ids
      ids = enrollment_scope(start_date: @start_date, end_date: @end_date).
        joins(:project, :organization).
        distinct.
        pluck(:client_id).
        map{ |id| [self.class.name, id] }
      self.class.transaction do
        Reporting::MonthlyClientIds.where(report_type: self.class.name).delete_all
        Reporting::MonthlyClientIds.import([:report_type, :client_id], ids)
      end
    end

    # Group clients by month and client_id
    # Loop over all of the open enrollments,
    def set_enrollments_by_client ids
      @enrollments_by_client = {}
      # Cleanup RAM before starting the next batch
      GC.start
      @date_range.map{|d| [d.year, d.month]}.uniq.each do |year, month|
        # fetch open enrollments for the given month
        enrollment_scope(start_date: Date.new(year, month, 1), end_date: Date.new(year, month, -1)).
          joins(:project, :organization).
          where(client_id: ids).
          pluck(*enrollment_columns).map do |row|
            OpenStruct.new(enrollment_columns.zip(row).to_h)
          end.each do |enrollment|
          entry_month = enrollment.first_date_in_program.month
          entry_year = enrollment.first_date_in_program.year
          exit_month = enrollment.last_date_in_program&.month
          exit_year = enrollment.last_date_in_program&.year
          client_id = enrollment.client_id

          entered_in_month = entry_month == month && entry_year == year
          exited_in_month = exit_month.present? && exit_month == month && exit_year == year
          mid_month = Date.new(year, month, 15)

          client_enrollment = self.class.new(
            mid_month: mid_month,
            month: month,
            year: year,
            client_id: client_id,
            enrollment_id: enrollment.id,
            head_of_household: enrollment[:head_of_household],
            household_id: enrollment.household_id.presence || "c_#{client_id}",
            destination_id: enrollment.destination,
            enrolled: true, # everyone will be enrolled
            active: active_in_month?(client_id: client_id, project_type: enrollment.computed_project_type, month: month, year: year),
            entered: entered_in_month,
            exited: exited_in_month,
            project_id: project_id(enrollment.project_id, enrollment.data_source_id),
            organization_id: organization_id(enrollment.organization_id, enrollment.data_source_id),
            project_type: enrollment.computed_project_type,
            entry_date: enrollment.first_date_in_program,
            exit_date: enrollment.last_date_in_program,
            first_enrollment: first_record?(enrollment),
            days_since_last_exit: nil,
            prior_exit_project_type: nil,
            prior_exit_destination_id: nil,

            calculated_at: Time.zone.now,
          )
          @enrollments_by_client[client_id] ||= []
          @enrollments_by_client[client_id] << client_enrollment
        end
      end
      @enrollments_by_client
    end

    def enrollment_columns
      @enrollment_columns ||= [
        :id,
        :client_id,
        :first_date_in_program,
        :last_date_in_program,
        :project_id,
        :organization_id,
        :data_source_id,
        :head_of_household,
        :household_id,
        :computed_project_type,
        :destination,
      ]
    end

    # By client, for each enrollment that is an entry in the month,
    # figure out the most recent exit (where there wasn't an ongoing enrollment)
    # and populate the days_since_last_exit and prior_exit_project_type as appropriate
    def set_prior_enrollments
      @enrollments_by_client.each do |client_id, enrollments|
        # find the next enrollment where entered == true
        # If all other enrollments in the current month are exits and the max exit date is
        # before the entry date, make note.
        # If the prior month is empty, or only contains exits,
        # Go back in time through the enrollments looking for a month where all enrollments
        # exited == true
        # get the latest exit date
        first_month = enrollments.first.month
        first_year = enrollments.first.year
        grouped_enrollments = enrollments.group_by{|m| [m.year, m.month]}
        grouped_enrollments.each do |(year, month), ens|
          ens.each do |en|
            if en.entered
              entry_date = en.entry_date
              current_year = en.year
              current_month = en.month

              # check current month for exits
              other_enrollments_in_current_month = ens - [en]
              if other_enrollments_in_current_month.present? && other_enrollments_in_current_month.all?(&:exited)
                max_exit_enrollment = other_enrollments_in_current_month.sort_by(&:exit_date).last
                if max_exit_enrollment.exit_date < entry_date
                  en.days_since_last_exit = (en.entry_date - max_exit_enrollment.exit_date).to_i
                  en.prior_exit_project_type = max_exit_enrollment.project_type
                  en.prior_exit_destination_id = max_exit_enrollment.destination_id
                end
              elsif other_enrollments_in_current_month.present? && other_enrollments_in_current_month.all?(&:entered)
                min_entry_date = other_enrollments_in_current_month.sort_by(&:entry_date).first.entry_date
                next if min_entry_date < entry_date
              end
              next if en.days_since_last_exit.present?

              # short circuit if prior month contains ongoing enrollments
              prev = previous_month(current_year, current_month)
              previous_enrollments = grouped_enrollments[[prev.year, prev.month]]
              next if previous_enrollments.present? && ! previous_enrollments.all?(&:exited)

              # Check back through time
              while(current_year >= first_year && current_month >= first_month) do
                prev = previous_month(current_year, current_month)
                current_month = prev.month
                current_year = prev.year

                current_enrollments = grouped_enrollments[[current_year, current_month]]
                if current_enrollments.present? && current_enrollments.all?(&:exited)
                  previous_exit = current_enrollments.sort_by(&:exit_date).last
                  en.days_since_last_exit = (en.entry_date - previous_exit.exit_date).to_i
                  en.prior_exit_project_type = previous_exit.project_type
                  en.prior_exit_destination_id = previous_exit.destination_id
                  break
                end
              end
            end
          end
        end
      end
    end

    def organization_id organization_id, data_source_id
      @organziations ||= GrdaWarehouse::Hud::Organization.pluck(:id, :OrganizationID, :data_source_id).map do |id, org_id, ds_id|
        [[ds_id, org_id], id]
      end.to_h
      @organziations[[data_source_id, organization_id]]
    end

    def project_id project_id, data_source_id
      @projects ||= GrdaWarehouse::Hud::Project.pluck(:id, :ProjectID, :data_source_id).map do |id, p_id, ds_id|
        [[ds_id, p_id], id]
      end.to_h
      @projects[[data_source_id, project_id]]
    end

    def previous_month year, month
      Date.new(year, month, 1) - 1.month
    end

    def actives_in_month
      @actives_in_month ||= begin
        acitives = {}
        GrdaWarehouse::ServiceHistoryService.homeless.
        service_within_date_range(start_date: @start_date, end_date: @end_date).
        where(service_history_enrollment_id: enrollment_scope(start_date: @start_date, end_date: @end_date).select(:id)).
        distinct.
        pluck(
          :client_id,
          :project_type,
          Arel.sql(cast(datepart(GrdaWarehouse::ServiceHistoryService, 'month', shs_t[:date]), 'INTEGER').to_sql),
          Arel.sql(cast(datepart(GrdaWarehouse::ServiceHistoryService, 'year', shs_t[:date]), 'INTEGER').to_sql),
        ).each do |id, project_type, month, year|
          acitives[id] ||= []
          acitives[id] << [year, month, project_type]
        end
        acitives
      end
    end

    def active_in_month? client_id:, project_type:, month:, year:
      actives_in_month[client_id]&.include?([year, month, project_type]) || false
    end

    def first_record? enrollment
      @first_records ||= first_scope.distinct.
        pluck(
          :client_id,
          Arel.sql(p_t[:id].to_sql),
          :first_date_in_program,
        ).map do |client_id, p_id, date|
          [client_id, [p_id, date]]
        end.to_h
      @first_records[enrollment.client_id] == [project_id(enrollment.project_id, enrollment.data_source_id), enrollment.first_date_in_program]
    end

    def enrollment_scope
      raise NotImplementedError
    end

    def sub_population_title
      raise NotImplementedError
    end

    def sub_population
      raise NotImplementedError
    end

    def active_scope start_date:, end_date:
      enrollment_scope(start_date: start_date, end_date: end_date).
        with_service_between(start_date: start_date, end_date: end_date).
        where(shs_t[:date].between(start_date..end_date))
    end

    def first_scope
      enrollment_source.first_date.where(client_id: enrollment_scope(start_date: @start_date, end_date: @end_date).select(:client_id)).
        joins(:project, :organization)
    end

    def enrollment_source
      GrdaWarehouse::ServiceHistoryEnrollment.homeless
    end

    def self.sub_tables
      available_types.map do |name, klass|
        [
          name, {
            table_name: "warehouse_partitioned_monthly_reports_#{name}",
            type: klass.name,
          },
        ]
      end.to_h
    end

    def self.parent_table
      :warehouse_partitioned_monthly_reports
    end

    def self.remainder_table
      :warehouse_partitioned_monthly_reports_unknown
    end

  end
end