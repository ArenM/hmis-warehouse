require 'rails_helper'
require 'models/exporters/hmis_twenty_twenty/project_setup.rb'
require 'models/exporters/hmis_twenty_twenty/multi_project_tests.rb'
require 'models/exporters/hmis_twenty_twenty/enrollment_setup.rb'
require 'models/exporters/hmis_twenty_twenty/multi_enrollment_tests.rb'

def project_test_type
  'data source-based'
end

RSpec.describe Exporters::HmisTwentyTwenty::Base, type: :model do
  include_context '2020 project setup'
  include_context '2020 enrollment setup'

  let(:involved_project_ids) { data_source.project_ids.first(3) }

  let(:exporter) do
    Exporters::HmisTwentyTwenty::Base.new(
      start_date: 1.week.ago.to_date,
      end_date: Date.current,
      projects: involved_project_ids,
      period_type: 3,
      directive: 3,
      user_id: user.id,
    )
  end

  include_context '2020 multi-project tests'
  include_context '2020 multi-enrollment tests'
end