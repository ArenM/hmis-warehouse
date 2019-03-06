class CensusesController < ApplicationController
  before_action :require_can_view_censuses!
  include ArelHelper
  # default view grouped by project
  def index
    # Whitelist census types
    klass = Censuses::Base.available_census_types.detect{|m| m.to_s == params[:type]} || Censuses::CensusBedNightProgram
    @census = klass.new
    @start_date = params[:start_date].try(:to_date) || 1.month.ago.to_date
    @end_date = params[:end_date].try(:to_date) || 1.day.ago.to_date
    @types = census_types
  end

  def details
    klass = Censuses::Base.available_census_types.detect{|m| m.to_s == params[:type]} || Censuses::CensusByProgram
    census = klass.new
    @date = params[:date].to_date
    if params[:project].present?
      @census_detail_name = census.detail_name(params[:project])
      ds_id, org_id, p_id = params[:project].split('-')
      @clients = census.clients_for_date(@date, ds_id, org_id, p_id)

      @yesterday_client_count = census.clients_for_date(@date - 1.day, ds_id, org_id, p_id).size
      @prior_year_averages = census.prior_year_averages(@date.year - 1, ds_id, org_id, p_id)
  
    elsif params[:project_type].present?
      # Whitelist project_types
      project_type =  GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPES.keys.detect{|m| m == params[:project_type].downcase.to_sym}

      @census_detail_name = census.detail_name(project_type)

      pt_codes = GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPES[project_type]
      sh_scope = GrdaWarehouse::ServiceHistoryService.joins(:client).where(project_type: pt_codes, date: @date)

      base_project_scope = project_scope.joins(:service_history).distinct

      if params[:veteran].present?
        if params[:veteran] == 'Veteran Count'
          @census_detail_name = "Veterans in #{@census_detail_name}"
          @clients = census.clients_for_date(@date, project_type, :veterans)
          @yesterday_client_count = census.clients_for_date(@date - 1.day, project_type,:veterans).size
          @prior_year_averages = census.prior_year_averages(@date.year - 1, project_type, :veterans)
        else
          @census_detail_name = "Non-Veterans in #{@census_detail_name}"
          @clients = census.clients_for_date(@date, project_type, :non_veterans)
          @yesterday_client_count = census.clients_for_date(@date - 1.day, project_type,:non_veterans).size
          @prior_year_averages = census.prior_year_averages(@date.year - 1, project_type, :non_veterans)
        end
      else
        @clients = census.clients_for_date(@date, project_type)
        @yesterday_client_count = census.clients_for_date(@date - 1.day, project_type).size
        @prior_year_averages = census.prior_year_averages(@date.year - 1, project_type, :all_clients)
      end
    else
      @census_detail_name = 'All'
      @clients = census.clients_for_date(@date)
      @yesterday_client_count = census.clients_for_date(@date - 1.day).size
    end
    @involved_projects = @clients.map{|row| [row['project_id'], row['ProjectName']]}.to_h
    respond_to do |format|
      format.html {}
      format.xlsx {}
    end
  end

  def date_range
    klass = Censuses::Base.available_census_types.detect{|m| m.to_s == params[:type]} || Censuses::CensusByProgram
    @census = klass.new
    start_date = params[:start_date]
    end_date = params[:end_date]
    # Allow single program display
    if params[:project_id].present? && params[:data_source_id].present?
      render json: @census.for_date_range(start_date, end_date, params[:data_source_id].to_i, params[:project_id].to_i)
    else
      render json: @census.for_date_range(start_date, end_date)
    end
  end

  private def project_scope
    GrdaWarehouse::Hud::Project.all
  end

  private def census_types
    {
      'ES Bed-night only shelters': 'Censuses::CensusBedNightProgram',
      'By Project Type': 'Censuses::CensusByProjectType',
      'By Program': 'Censuses::CensusByProgram',
      'Veteran': 'Censuses::CensusVeteran',
    }
  end

end
