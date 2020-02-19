###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

class OrganizationsController < ApplicationController
  include ArelHelper
  before_action :require_can_delete_projects_or_data_sources!, only: [:destroy]
  before_action :set_organization, only: [:destroy]

  def destroy
    name = @organization.OrganizationName
    @organization.destroy_dependents!
    @organization.destroy
    flash[:notice] = "Organization: #{name} was successfully removed."
    respond_with @organization, location: data_source_path(@organization.data_source)
  end

  private def organization_scope
    organization_source.viewable_by current_user
  end

  private def organization_source
    GrdaWarehouse::Hud::Organization
  end

  private def set_organization
    @organization = organization_scope.find(params[:id].to_i)
  end

  def flash_interpolation_options
    { resource_name: 'Organization' }
  end
end
