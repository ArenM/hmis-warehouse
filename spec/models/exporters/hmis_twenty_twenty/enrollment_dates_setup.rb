RSpec.shared_context '2020 enrollment dates setup', shared_context: :metadata do
  # Setup such that there are more than 3 of each item, but three fall within the date range
  let!(:enrollments) { create_list :hud_enrollment, 5, data_source_id: data_source.id }
  let!(:clients) { create_list :hud_client, 5, data_source_id: data_source.id }
  let!(:destination_data_source) { create :grda_warehouse_data_source }
  let!(:destination_clients) do
    clients.map do |client|
      attributes = client.attributes
      attributes['data_source_id'] = destination_data_source.id
      attributes['id'] = nil
      dest_client = GrdaWarehouse::Hud::Client.create(attributes)
      GrdaWarehouse::WarehouseClient.create(
        id_in_source: client.PersonalID,
        data_source_id: client.data_source_id,
        source_id: client.id,
        destination_id: dest_client.id,
      )
    end
  end
  let!(:disabilities) { create_list :hud_disability, 5, data_source_id: data_source.id, InformationDate: 1.week.ago }
  let!(:enrollment_cocs) { create_list :hud_enrollment_coc, 5, data_source_id: data_source.id, InformationDate: 1.week.ago }
  let!(:employment_educations) { create_list :hud_employment_education, 5, data_source_id: data_source.id, InformationDate: 1.week.ago }
  let!(:health_and_dvs) { create_list :hud_health_and_dv, 5, data_source_id: data_source.id, InformationDate: 1.week.ago }
  let!(:income_benefits) { create_list :hud_income_benefit, 5, data_source_id: data_source.id, InformationDate: 1.week.ago }
  let!(:services) { create_list :hud_service, 5, data_source_id: data_source.id, DateProvided: 1.week.ago }
  let!(:exits) { create_list :hud_exit, 5, data_source_id: data_source.id }
  let!(:assessments) { create_list :hud_assessment, 5, data_source_id: data_source.id, AssessmentDate: Date.yesterday }
  let!(:assessment_questions) { create_list :hud_assessment_question, 5, data_source_id: data_source.id }
  let!(:assessment_results) { create_list :hud_assessment_result, 5, data_source_id: data_source.id }
  let!(:events) { create_list :hud_event, 5, data_source_id: data_source.id }
  let!(:current_living_situations) { create_list :hud_current_living_situation, 5, data_source_id: data_source.id }

  # Project Related
  # 'Affiliation.csv' => affiliation_source,
  # 'Funder.csv' => funder_source,
  # 'Inventory.csv' => inventory_source,
  # 'Organization.csv' => organization_source,
  # 'ProjectCoC.csv' => project_coc_source,

  # Enrollment Related
  # 'Disabilities.csv' => disability_source,
  # 'EmploymentEducation.csv' => employment_education_source,
  # 'EnrollmentCoC.csv' => enrollment_coc_source,
  # 'Exit.csv' => exit_source,
  # 'HealthAndDV.csv' => health_and_dv_source,
  # 'IncomeBenefits.csv' => income_benefits_source,
  # 'Services.csv' => service_source,
  # 'CurrentLivingSituation.csv' => current_living_situation_source,
  # 'Assessment.csv' => assessment_source,
  # 'AssessmentQuestions.csv' => assessment_question_source,
  # 'AssessmentResults.csv' => assessment_result_source,
  # 'Event.csv' => event_source,

  #  Other
  # 'Export.csv' => export_source,
  # 'Client.csv' => client_source,
  # 'Enrollment.csv' => enrollment_source,
  # 'Project.csv' => project_source,
  # 'User.csv' => user_source,

  class EnrollmentRelatedHmisTwentyTwentyTests
    TESTS ||= [
      {
        list: :disabilities,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::Disability,
        export_method: :export_disabilities,
      },
      {
        list: :enrollment_cocs,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::EnrollmentCoc,
        export_method: :export_enrollment_cocs,
      },
      {
        list: :employment_educations,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::EmploymentEducation,
        export_method: :export_employment_educations,
      },
      {
        list: :health_and_dvs,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::HealthAndDv,
        export_method: :export_health_and_dvs,
      },
      {
        list: :income_benefits,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::IncomeBenefit,
        export_method: :export_income_benefits,
      },
      {
        list: :services,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::Service,
        export_method: :export_services,
      },
      {
        list: :exits,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::Exit,
        export_method: :export_exits,
      },
      {
        list: :assessments,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::Assessment,
        export_method: :export_assessments,
      },
      {
        list: :assessment_questions,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::AssessmentQuestion,
        export_method: :export_assessment_questions,
      },
      {
        list: :assessment_results,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::AssessmentResult,
        export_method: :export_assessment_results,
      },
      {
        list: :events,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::Event,
        export_method: :export_events,
      },
      {
        list: :current_living_situations,
        klass: GrdaWarehouse::Export::HmisTwentyTwenty::CurrentLivingSituation,
        export_method: :export_current_living_situations,
      },
    ].freeze
  end

  def csv_file_path(klass)
    File.join(exporter.file_path, klass.file_name)
  end
end

RSpec.configure do |rspec|
  rspec.include_context '2020 enrollment dates setup', include_shared: true
end
