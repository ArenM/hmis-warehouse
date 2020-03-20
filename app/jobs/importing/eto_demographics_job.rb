###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module Importing
  class EtoDemographicsJob < BaseJob
    queue_as :low_priority

    def initialize(client_ids:)
      @client_ids = client_ids
    end

    def perform
      EtoApi::Tasks::UpdateEtoData.new(client_ids: @client_ids).update_demographics!
    end

    def max_attempts
      1
    end
  end
end