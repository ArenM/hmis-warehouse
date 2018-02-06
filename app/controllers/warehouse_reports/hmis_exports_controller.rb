module WarehouseReports
  class HmisExportsController < ApplicationController
    before_action :require_can_export_hmis_data!
    before_action :set_export, only: [:show, :destroy]
    before_action :set_jobs, only: [:index, :running, :create]
    before_action :set_exports, only: [:index, :running, :create]

    def index
      @filter = ::Filters::HmisExport.new(user_id: current_user.id)
      @all_project_names = GrdaWarehouse::Hud::Project.order(ProjectName: :asc).pluck(:ProjectName)
    end

    def running

    end

    def set_jobs
      @jobs = Delayed::Job.where(queue: :hmis_six_one_one_export).order(run_at: :desc)
    end

    def set_exports
      @exports = export_source.ordered.
        for_list.
        limit(50)
    end

    def create
      @filter = ::Filters::HmisExport.new(report_params.merge(user_id: current_user.id))
      if @filter.valid?
        WarehouseReports::HmisSixOneOneExportJob.perform_later(@filter.options_for_hmis_export(:six_one_one).as_json)
        redirect_to warehouse_reports_hmis_exports_path
      else
        render :index
      end
    end

    def destroy
      
    end

    def show

    end

    def set_export
      export_source.find(params[:id].to_i)
    end

    def export_source
      GrdaWarehouse::HmisExport
    end

    def report_params
      params.require(:filter).permit(
        :start_date, 
        :end_date,
        :hash_status,
        :include_deleted,
        project_ids: [],
        project_group_ids: [],
        organization_ids: [],
        data_source_ids: []
      )
    end

  end
end