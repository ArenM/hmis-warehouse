###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

# dev projects -- with affiliation: 61; single RRH: 44

class WarehouseReport::RrhReport
  include ArelHelper

  attr_accessor :project_ids, :start_date, :end_date, :subpopulation, :household_type
  def initialize project_ids:, start_date:, end_date:, subpopulation:, household_type:
    @project_ids = project_ids
    @start_date = start_date
    @end_date = end_date
    @subpopulation = Reporting::Housed.rrh.subpopulation(subpopulation)
    @household_type = Reporting::Housed.rrh.household_type(household_type)
  end

  def pre_placement_project_name
    @pre_placement_project_name ||= unless all_projects
      housed_scope.where.not(service_project: nil).
        where.not(service_project: 'No Service Enrollment').
        distinct.
        pluck(:service_project).
        join(', ')
    else
      ''
    end
  end

  def stabilization_project_name
    @stabilization_project_name ||= unless all_projects
      housed_scope.where.not(residential_project: nil).
        distinct.
        pluck(:residential_project).
        join(', ')
    else
      ''
    end
  end

  def project_names
    @project_names ||=
    (
      pre_placement_project_name.split(', ') +
      stabilization_project_name.split(', ')
    ).uniq.
      join(', ')
  end

  def service_project_names
    @service_project_names ||= housed_scope.distinct.pluck(:service_project)
  end

  def residential_project_names
    @residential_project_names ||= housed_scope.distinct.pluck(:residential_project)
  end

  # newly enrolled during date range
  def entering_pre_placement
    housed_scope.entering_pre_placement(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  # exited pre-placement during date range if two projects
  # received move-in-date if one project
  def exiting_pre_placement
    housed_scope.exiting_pre_placement(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  def entering_stabilization
    housed_scope.entering_stabilization(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  def exiting_stabilization
    housed_scope.exiting_stabilization(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  def days_in_pre_placement
    @days_in_pre_placement ||= housed_scope.
      enrolled_pre_placement(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:search_start, :search_end)
  end

  def average_days_in_pre_placement
    days = days_in_pre_placement.map do |entry_date, exit_date|
      exit_date ||= end_date
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / days_in_pre_placement.count).round
  end

  def days_in_stabilization
    @days_in_stabilization ||= housed_scope.
      enrolled_stabilization(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:housed_date, :housing_exit)
  end

  def average_days_in_stabilization
    days = days_in_stabilization.map do |entry_date, exit_date|
      exit_date ||= end_date
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / days_in_stabilization.count).round
  end

  def leavers_pre_placement
    @leavers_pre_placement ||= housed_scope.
      leavers_pre_placement(start_date: start_date, end_date: end_date).
      distinct
  end

  def leavers_pre_placement_exit_to_stabilization
    @leavers_pre_placement_exit_to_stabilization ||= housed_scope.
      exited_pre_placement_to_stabilization(start_date: start_date, end_date: end_date).
      distinct
  end

  def average_days_leavers_pre_placement_exit_to_stabilization
    days = leavers_pre_placement_exit_to_stabilization.pluck(:search_start, :search_end).map do |entry_date, exit_date|
      exit_date ||= end_date
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / leavers_pre_placement_exit_to_stabilization.count).round
  end

  def leavers_pre_placement_exit_no_stabilization
    @leavers_pre_placement_exit_no_stabilization ||= housed_scope.
      exited_pre_placement_no_stabilization(start_date: start_date, end_date: end_date).
      distinct
  end

  def average_days_leavers_pre_placement_exit_no_stabilization
    days = leavers_pre_placement_exit_no_stabilization.pluck(:search_start, :search_end).map do |entry_date, exit_date|
      exit_date ||= end_date
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / leavers_pre_placement_exit_no_stabilization.count).round
  end

  def leavers_average_pre_placement
    days = leavers_pre_placement.pluck(:search_start, :search_end).map do |entry_date, exit_date|
      (exit_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / leavers_pre_placement.count).round
  end

  def stayers_days_in_pre_placement
    @stayers_days_in_pre_placement ||= housed_scope.
      stayers_pre_placement(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:search_start).compact.map do |entry_date|
        [entry_date, end_date]
      end
  end

  def stayers_average_days_in_pre_placement
    days = stayers_days_in_pre_placement.map do |entry_date, exit_date|
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / stayers_days_in_pre_placement.count).round
  end

  def leavers_days_in_stabilization
    @leavers_days_in_stabilization ||= housed_scope.
      leavers_stabilization(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:housed_date, :housing_exit)
  end

  def leavers_average_days_in_stabilization
    days = leavers_days_in_stabilization.map do |entry_date, exit_date|
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / leavers_days_in_stabilization.count).round
  end

  def stayers_days_in_stabilization
    @stayers_days_in_stabilization ||= housed_scope.
      stayers_stabilization(start_date: start_date, end_date: end_date).
      distinct.
      where.not(housed_date: nil).
      pluck(:housed_date).compact.map do |entry_date|
        [entry_date, end_date]
      end
  end

  def stayers_average_days_in_stabilization
    days = stayers_days_in_stabilization.map do |entry_date, exit_date|
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / stayers_days_in_stabilization.count).round
  end

  def in_stabilization
    @in_stabilization ||= housed_scope.
      enrolled_stabilization(start_date: start_date, end_date: end_date).
      distinct
  end

  def leavers_days
    @leavers_days ||= housed_scope.
      leavers(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:search_start, :housing_exit)
  end

  def leavers_average_days
    days = leavers_days.map do |entry_date, exit_date|
      (exit_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / leavers_days.count).round
  end

  def stayers_days
    @stayers_days ||= housed_scope.
      stayers(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:search_start).compact.map do |entry_date|
        [entry_date, end_date]
      end
  end

  def stayers_average_days
    days = stayers_days.map do |entry_date, exit_date|
      (exit_date.to_date - entry_date).to_i
    end.sum
    return days if days == 0
    (days.to_f / stayers_days.count).round
  end


  def destinations
    @destinations ||= begin
      @destinations = {
        'returned to shelter' => {},
        'exited to other institution' => {},
        'successful exit to PH' => {},
        'exited to temporary destination' => {},
        'unknown outcome' => {},
      }
      housed_scope.
        exiting_stabilization(start_date: start_date, end_date: end_date).
        where(ho_t[:destination].not_eq(nil)).
        distinct.
        pluck(:client_id, :destination).map do |client_id, dest_id|
          destination = destination_bucket(client_id, dest_id)
          @destinations[destination][:destination] ||= destination_bucket(client_id, dest_id)
          @destinations[destination][:count] ||= 0
          @destinations[destination][:client_ids] ||= Set.new
          # Only count each client once per bucket
          @destinations[destination][:count] += 1 unless @destinations[destination][:client_ids].include?(client_id)
          @destinations[destination][:client_ids] << client_id
        end
      @destinations.delete_if{|_,v| v == {} }
    end
  end

  def destination_bucket client_id, dest_id
    return 'returned to shelter' if returns_to_shelter.keys.include?(client_id)
    return 'exited to other institution' if HUD.institutional_destinations.include?(dest_id)
    return 'successful exit to PH' if HUD.permanent_destinations.include?(dest_id)
    return 'exited to temporary destination' if HUD.temporary_destinations.include?(dest_id)
    return 'unknown outcome'
  end

  def ph_leavers
    housed_scope.
      exiting_stabilization(start_date: start_date, end_date: end_date).
      ph_destinations.
      distinct
  end

  # returns to shelter after exiting to permanent housing
  def returns_to_shelter
    @returns_to_shelter ||= begin
      leavers_with_date = ph_leavers.pluck(:client_id, :housing_exit).to_h
      return {} unless leavers_with_date.present?
      returner_ids = Reporting::Return.where(client_id: leavers_with_date.keys).distinct.pluck(:client_id)
      rr_t = Reporting::Return.arel_table
      returns = {}
      returner_ids.each do |id|
        # find the first start date after the exit to PH
        first_return = Reporting::Return.where(client_id: id).
          where(rr_t[:first_date_in_program].gt(leavers_with_date[id])).
          minimum(:first_date_in_program)
        if first_return.present?
          exit_date = leavers_with_date[id]
          days_to_return = (first_return - exit_date).to_i.abs
          returns[id] = {
            entry_date: first_return,
            exit_date: leavers_with_date[id],
            days_to_return: days_to_return,
            bucket: bucket(days_to_return),
            client_id: id,
          }
        end
      end
      returns
    end
  end

  def percent_returns_to_shelter
    return 0 unless ph_leavers.exists?
    (returns_to_shelter.uniq.count.to_f/ph_leavers.select(:client_id).count * 100).round(2)
  end

  def bucketed_returns
    @bucketed_returns ||= {}
    grouped_returns = returns_to_shelter.values.group_by{|m| m[:bucket]}
    length_of_time_buckets.each do |_, bucket_text|
      if grouped_returns[bucket_text].present?
        @bucketed_returns[bucket_text] = grouped_returns[bucket_text].count
      end
    end
    return @bucketed_returns.to_a
  end

  def returns_for_chart
    {
      labels: bucketed_returns.map(&:first),
      data: [['Client count'] + bucketed_returns.map(&:last)],
    }
  end

  def time_in_pre_placement_leavers_data
    support = pre_placement_average_stay_by_month(leavers_pre_placement)
    months = months_for(start_date: start_date, end_date: end_date)
    {
      labels: ['x'] + months,
      data: [['x'] + months] + data_from(months, support),
      support: support,
    }
  end

  def time_in_pre_placement_exit_to_stabilization_data
    support = pre_placement_average_stay_by_month(leavers_pre_placement_exit_to_stabilization)
    months = months_for(start_date: start_date, end_date: end_date)
    {
      labels: ['x'] + months,
      data: [['x'] + months] + data_from(months, support),
      support: support,
    }
  end

  def time_in_pre_placement_exit_no_stabilization_data
    support = pre_placement_average_stay_by_month(leavers_pre_placement_exit_no_stabilization)
    months = months_for(start_date: start_date, end_date: end_date)
    {
      labels: ['x'] + months,
      data: [['x'] + months] + data_from(months, support),
      support: support,
    }
  end

  def time_in_stabilization_data
    support = pre_placement_average_stay_by_month(in_stabilization)
    months = months_for(start_date: start_date, end_date: end_date)
    {
      labels: ['x'] + months,
      data: [['x'] + months] + data_from(months, support),
      support: support,
    }
  end

  # Supporting methods

  def data_from months, support
    data = {}
    project_names = support.values.map(&:keys).flatten.uniq
    project_names.each do |project_name|
      months.each do |month|
        d = support[month][project_name]
        data[project_name] ||= [project_name.gsub(/ - \(\d+\)$/, '')]
        data[project_name] << (d.try(:[], 'average') || 0)
      end
    end
    return data.values
  end

  def months_for start_date:, end_date:
    (start_date.to_date..end_date.to_date).map{ |m| m.strftime('%b %Y') }.uniq
  end

  def pre_placement_average_stay_by_month client_scope
    columns = [:search_start, :search_end, :service_project, :project_id]
    leavers = client_scope.pluck(*columns).map do |row|
      Hash[columns.zip(row)]
    end.group_by do |row|
      row[:service_project]
    end
    month_data = {}
    months_for(start_date: start_date, end_date: end_date).each do |month_year|
      beginning_of_month = Date.parse "#{month_year} 01"
      end_of_month = beginning_of_month.end_of_month

      month_data[month_year] ||= {}
      month_data[month_year]['All'] ||= {}
      month_data[month_year]['All']['data'] ||= []
      service_project_names.each do |project_name|
        if @project_ids != :all
          month_data[month_year][project_name] ||= {}
          month_data[month_year][project_name]['data'] ||= []
        end
        if leavers[project_name].blank?
          # comment this out to remove blanks from the average
          month_data[month_year]['All']['data'] << 0
          month_data[month_year][project_name]['data'] << 0 if @project_ids != :all
        else
          leavers[project_name].each do |row|
            if row[:search_end] > end_of_month
              use_end_date = end_of_month
            else
              use_end_date = row[:search_end]
            end
            next if row[:search_start] >= use_end_date
            month_data[month_year]['All']['data'] << (use_end_date - row[:search_start]).to_i

            if @project_ids != :all
              month_data[month_year][project_name]['data'] << (use_end_date - row[:search_start]).to_i
            end
          end
        end
      end
    end
    month_data.each do |month_year, counts|
      counts.each do |project_name, project_data|
        month_data[month_year][project_name]['count'] = project_data['data'].count
        if project_data['data'].count.zero?
          month_data[month_year][project_name]['average'] = 0
        else
          month_data[month_year][project_name]['average'] = (project_data['data'].sum.to_f / project_data['data'].count).round(2)
        end
      end
    end

    return month_data
  end

  def stabilization_average_stay_by_month client_scope
    columns = [:housed_date, :housing_exit, :residential_project, :project_id]
    clients = client_scope.pluck(*columns).map do |row|
      Hash[columns.zip(row)]
    end.group_by do |row|
      row[:residential_project]
    end
    month_data = {}
    months_for(start_date: start_date, end_date: end_date).each do |month_year|
      beginning_of_month = Date.parse "#{month_year} 01"
      end_of_month = beginning_of_month.end_of_month
      month_data[month_year] ||= {}
      month_data[month_year]['All'] ||= {}
      month_data[month_year]['All']['data'] ||= []
      residential_project_names.each do |project_name|
        if @project_ids != :all
          month_data[month_year][project_name] ||= {}
          month_data[month_year][project_name]['data'] ||= []
        end

        if clients[project_name].blank?
          # comment this out to remove blanks from the average
          month_data[month_year]['All']['data'] << 0
          month_data[month_year][project_name]['data'] << 0 if @project_ids != :all
        else
          clients[project_name].each do |row|
            if row[:housing_exit] > end_of_month
              use_end_date = end_of_month
            else
              use_end_date = row[:housing_exit]
            end
            next if row[:housed_date] >= use_end_date

            month_data[month_year]['All']['data'] << (use_end_date - row[:housed_date]).to_i

            if @project_ids != :all
              month_data[month_year][project_name]['data'] << (use_end_date - row[:housed_date]).to_i
            end
          end
        end
      end
    end
    month_data.each do |month_year, counts|
      counts.each do |project_name, project_data|
        month_data[month_year][project_name]['count'] = project_data['data'].count
        if project_data['data'].count.zero?
          month_data[month_year][project_name]['average'] = 0
        else
          month_data[month_year][project_name]['average'] = (project_data['data'].sum.to_f / project_data['data'].count).round(2)
        end
      end
    end

    return month_data
  end

  def enrolled_client_ids
    housed_scope.
      enrolled(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  def pre_placement_client_ids
    housed_scope.
      enrolled_pre_placement(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  def stabilization_client_ids
    housed_scope.
      enrolled_stabilization(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:client_id)
  end

  def bucket days
    length_of_time_buckets.select{ |k,_| k.include?(days) }&.values&.first
  end

  def length_of_time_buckets
    @length_of_time_buckets ||= {
      (0..7) => 'Less than 1 week',
      (8..30) => '1 week to one month',
      (31..91) => '1 month to 3 months',
      (92..182) => '3 months to 6 months',
      (183..364) => '3 months to 1 year',
      (365..728) => '1 year to 2 years',
      (729..Float::INFINITY) => '2 years or more',
    }
  end

  # returns array of clients with id, first name, last name who match the metric
  def support_for metric, params=nil
    case metric
    when :enrolled_clients
      client_ids = enrolled_client_ids
    when :enrolled_in_pre_placement
      client_ids = pre_placement_client_ids
    when :enrolled_in_stabilization
      client_ids = stabilization_client_ids
    when :entering_pre_placement
      client_ids = entering_pre_placement
    when :exiting_pre_placement
      client_ids = exiting_pre_placement
    when :entering_stabilization
      client_ids = entering_stabilization
    when :exiting_stabilization
      client_ids = exiting_stabilization
    when :pre_placement_any_exit
      project_name = valid_project_name(params[:selected_project])
      start_date = "#{params[:month]} 01".to_date
      end_date = start_date.end_of_month
      client_ids = leavers_pre_placement.where(service_project: project_name).
        leavers_pre_placement(start_date: start_date, end_date: end_date).
        pluck(:client_id)
    when :pre_placement_stabilization_exit
      project_name = valid_project_name(params[:selected_project])
      start_date = "#{params[:month]} 01".to_date
      end_date = start_date.end_of_month
      client_ids = leavers_pre_placement_exit_to_stabilization.where(service_project: project_name).
        exited_pre_placement_to_stabilization(start_date: start_date, end_date: end_date).
        pluck(:client_id)
    when :pre_placement_no_stabilization_exit
      project_name = valid_project_name(params[:selected_project])
      start_date = "#{params[:month]} 01".to_date
      end_date = start_date.end_of_month
      client_ids = leavers_pre_placement_exit_no_stabilization.where(service_project: project_name).
        exited_pre_placement_no_stabilization(start_date: start_date, end_date: end_date).
        pluck(:client_id)
    end
    client_source.where(id: client_ids).
      order(:LastName, :FirstName).
      pluck(:id, :FirstName, :LastName)
  end

  def valid_project_name name
    (service_project_names + residential_project_names).detect{|m| m == name}
  end

  # selected projects
  def projects
    @projects ||= project_source.where(id: @project_ids)
  end

  def project_source
    GrdaWarehouse::Hud::Project
  end

  def client_source
    GrdaWarehouse::Hud::Client
  end

  def housed_source
    Reporting::Housed.rrh
  end

  def housed_scope
    if ! all_projects
      housed_source.where(project_id: @project_ids).send(@subpopulation).send(@household_type)
    else
      housed_source.all.send(@subpopulation).send(@household_type)
    end
  end

  def all_projects
    @project_ids == :all
  end

  def ho_t
    housed_source.arel_table
  end

end