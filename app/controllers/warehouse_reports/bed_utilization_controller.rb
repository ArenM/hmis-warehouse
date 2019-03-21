module WarehouseReports
  class BedUtilizationController < ApplicationController
    include ArelHelper
    include WarehouseReportAuthorization

    def index
      options = {}
      if params[:mo].present?
        start_date = Date.parse "#{params[:mo][:year]}-#{params[:mo][:month]}-1"
        end_date = start_date.end_of_month
        options = params[:mo]
        options[:start] = start_date
        options[:end] = end_date
      end
      @mo = ::Filters::MonthAndOrganization.new options
      @mo.user = current_user
      if @mo.valid?
        @projects_with_counts = organization_scope.bed_utilization_by_project(filter: @mo)
      else
        @projects_with_counts = ( @mo.organization.projects.viewable_by(current_user).map{ |p| [ p, [] ] } rescue {} )
      end
      respond_to :html, :xlsx
    end

    def info project, projects_by_date, date
      ri = relevant_inventories project.inventories, date
      capacity = ri&.map(&:BedInventory)&.sum
      clients = projects_by_date[date].try(&:client_count).to_i
      {
        capacity:         capacity,
        persons:          clients,
        percent_capacity: capacity.try{ |c| ( clients / c.to_f * 100 ).round(1) if c > 0 }
      }
    end
    helper_method :info

    def avg_info project, projects_by_date, range
      persons = []
      percent_capacity = []
      range.to_a.each do |date|
        i = info project, projects_by_date, date
        persons << i[:persons]
        percent_capacity << i[:percent_capacity]
      end
      percent_capacity = percent_capacity.compact
      {
        persons: ( persons.sum.to_f / persons.length ).round(1),
        percent_capacity: ( ( percent_capacity.sum.to_f / percent_capacity.length ).round(1) if percent_capacity.any? )
      }
    end
    helper_method :avg_info

    # find the inventory closest in time to the reference date
    # this might not be the approved way to deal with it -- perhaps we only want the closest preceding inventory -- but
    # our inventory information is exceedingly spotty
    def relevant_inventories inventories, date
      GrdaWarehouse::Hud::Inventory.relevant_inventories(inventories: inventories, date: date)
    end
    helper_method :relevant_inventories

    def organization_scope
      GrdaWarehouse::Hud::Organization.viewable_by(current_user)
    end

  end
end
