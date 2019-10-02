###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

# Shows up as "My Agency's Clients"
module Assigned
  class AgenciesController < ApplicationController

    before_action :require_can_manage_an_agency!

    def index
      @users = User.
        active.
        where(agency_id: current_user.agency.id).
        order(:first_name, :last_name)
    end

  end
end