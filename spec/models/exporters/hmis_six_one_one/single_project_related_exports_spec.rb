require 'rails_helper'
require 'models/exporters/hmis_six_one_one/project_setup.rb'
require 'models/exporters/hmis_six_one_one/single_project_tests.rb'

RSpec.describe Exporters::HmisSixOneOne::Base, type: :model do
  include_context 'project setup'

  let(:exporter) do
    Exporters::HmisSixOneOne::Base.new(
      start_date: 1.week.ago.to_date,
      end_date: Date.current,
      projects: [projects.first.id],
      period_type: 3,
      directive: 3,
      user_id: user.id,
    )
  end

  include_context 'single-project tests'
end
