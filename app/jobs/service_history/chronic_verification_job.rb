###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module ServiceHistory
  class ChronicVerificationJob < BaseJob
    include ArelHelper
    include Rails.application.routes.url_helpers
    queue_as :high_priority

    def initialize client_id:, years:
      @client_id = client_id
      @years = years
    end

    def perform
      app = ActionDispatch::Integration::Session.new(Rails.application)

      app.get(pdf_window_client_history_path(client_id: @client_id, years: @years))
    end

    def enqueue(job, queue: :high_priority)
    end

    def max_attempts
      2
    end

  end
end