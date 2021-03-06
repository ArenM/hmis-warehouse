# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_27_151840) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accountable_care_organizations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.integer "mco_pid"
    t.string "mco_sl"
    t.boolean "active", default: true, null: false
  end

  create_table "agencies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "acceptable_domains"
  end

  create_table "agency_patient_referrals", id: :serial, force: :cascade do |t|
    t.integer "agency_id", null: false
    t.integer "patient_referral_id", null: false
    t.boolean "claimed", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agency_users", id: :serial, force: :cascade do |t|
    t.integer "agency_id", null: false
    t.integer "user_id", null: false
  end

  create_table "appointments", id: :serial, force: :cascade do |t|
    t.string "appointment_type"
    t.text "notes"
    t.string "doctor"
    t.string "department"
    t.string "sa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "appointment_time"
    t.string "id_in_source"
    t.string "patient_id"
    t.integer "data_source_id", default: 6, null: false
  end

  create_table "careplan_equipment", id: :serial, force: :cascade do |t|
    t.integer "careplan_id"
    t.integer "equipment_id"
  end

  create_table "careplan_services", id: :serial, force: :cascade do |t|
    t.integer "careplan_id"
    t.integer "service_id"
  end

  create_table "careplans", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "user_id"
    t.date "sdh_enroll_date"
    t.date "first_meeting_with_case_manager_date"
    t.date "self_sufficiency_baseline_due_date"
    t.date "self_sufficiency_final_due_date"
    t.date "self_sufficiency_baseline_completed_date"
    t.date "self_sufficiency_final_completed_date"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "patient_signed_on"
    t.datetime "provider_signed_on"
    t.boolean "locked", default: false, null: false
    t.datetime "initial_date"
    t.datetime "review_date"
    t.text "patient_health_problems"
    t.text "patient_strengths"
    t.text "patient_goals"
    t.text "patient_barriers"
    t.string "status"
    t.integer "responsible_team_member_id"
    t.integer "provider_id"
    t.integer "representative_id"
    t.datetime "responsible_team_member_signed_on"
    t.datetime "representative_signed_on"
    t.text "service_archive"
    t.text "equipment_archive"
    t.text "team_members_archive"
    t.text "goals_archive"
    t.datetime "patient_signature_requested_at"
    t.datetime "provider_signature_requested_at"
    t.integer "health_file_id"
    t.index ["patient_id"], name: "index_careplans_on_patient_id"
    t.index ["user_id"], name: "index_careplans_on_user_id"
  end

  create_table "claims", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.date "max_date"
    t.integer "job_id"
    t.integer "max_isa_control_number"
    t.integer "max_group_control_number"
    t.integer "max_st_number"
    t.text "claims_file"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "submitted_at"
    t.datetime "precalculated_at"
    t.string "result"
    t.integer "transaction_acknowledgement_id"
    t.index ["deleted_at"], name: "index_claims_on_deleted_at"
  end

  create_table "claims_amount_paid_location_month", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.integer "year"
    t.integer "month"
    t.integer "ip"
    t.integer "emerg"
    t.integer "respite"
    t.integer "op"
    t.integer "rx"
    t.integer "other"
    t.integer "total"
    t.string "year_month"
    t.string "study_period"
    t.index ["medicaid_id"], name: "index_claims_amount_paid_location_month_on_medicaid_id"
  end

  create_table "claims_claim_volume_location_month", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.integer "year"
    t.integer "month"
    t.integer "ip"
    t.integer "emerg"
    t.integer "respite"
    t.integer "op"
    t.integer "rx"
    t.integer "other"
    t.integer "total"
    t.string "year_month"
    t.string "study_period"
    t.index ["medicaid_id"], name: "index_claims_claim_volume_location_month_on_medicaid_id"
  end

  create_table "claims_ed_nyu_severity", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.string "category"
    t.float "indiv_pct"
    t.float "sdh_pct"
    t.float "baseline_visits"
    t.float "implementation_visits"
    t.index ["medicaid_id"], name: "index_claims_ed_nyu_severity_on_medicaid_id"
  end

  create_table "claims_roster", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.string "last_name"
    t.string "first_name"
    t.string "gender"
    t.date "dob"
    t.string "race"
    t.string "primary_language"
    t.boolean "disability_flag"
    t.float "norm_risk_score"
    t.integer "mbr_months"
    t.integer "total_ty"
    t.integer "ed_visits"
    t.integer "acute_ip_admits"
    t.integer "average_days_to_readmit"
    t.string "pcp"
    t.string "epic_team"
    t.integer "member_months_baseline"
    t.integer "member_months_implementation"
    t.integer "cost_rank_ty"
    t.float "average_ed_visits_baseline"
    t.float "average_ed_visits_implementation"
    t.float "average_ip_admits_baseline"
    t.float "average_ip_admits_implementation"
    t.float "average_days_to_readmit_baseline"
    t.float "average_days_to_implementation"
    t.string "case_manager"
    t.string "housing_status"
    t.integer "baseline_admits"
    t.integer "implementation_admits"
    t.index ["medicaid_id"], name: "index_claims_roster_on_medicaid_id"
  end

  create_table "claims_top_conditions", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.integer "rank"
    t.string "description"
    t.float "indiv_pct"
    t.float "sdh_pct"
    t.float "baseline_paid"
    t.float "implementation_paid"
    t.index ["medicaid_id"], name: "index_claims_top_conditions_on_medicaid_id"
  end

  create_table "claims_top_ip_conditions", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.integer "rank"
    t.string "description"
    t.float "indiv_pct"
    t.float "sdh_pct"
    t.float "baseline_paid"
    t.float "implementation_paid"
    t.index ["medicaid_id"], name: "index_claims_top_ip_conditions_on_medicaid_id"
  end

  create_table "claims_top_providers", id: :serial, force: :cascade do |t|
    t.string "medicaid_id", null: false
    t.integer "rank"
    t.string "provider_name"
    t.float "indiv_pct"
    t.float "sdh_pct"
    t.float "baseline_paid"
    t.float "implementation_paid"
    t.index ["medicaid_id"], name: "index_claims_top_providers_on_medicaid_id"
  end

  create_table "comprehensive_health_assessments", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "user_id"
    t.integer "health_file_id"
    t.integer "status", default: 0
    t.integer "reviewed_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "answers"
    t.datetime "completed_at"
    t.datetime "reviewed_at"
    t.string "reviewer"
    t.index ["health_file_id"], name: "index_comprehensive_health_assessments_on_health_file_id"
    t.index ["patient_id"], name: "index_comprehensive_health_assessments_on_patient_id"
    t.index ["reviewed_by_id"], name: "index_comprehensive_health_assessments_on_reviewed_by_id"
    t.index ["user_id"], name: "index_comprehensive_health_assessments_on_user_id"
  end

  create_table "cp_member_files", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "file"
    t.string "content"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cps", id: :serial, force: :cascade do |t|
    t.string "pid"
    t.string "sl"
    t.string "mmis_enrollment_name"
    t.string "short_name"
    t.string "pt_part_1"
    t.string "pt_part_2"
    t.string "address_1"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "key_contact_first_name"
    t.string "key_contact_last_name"
    t.string "key_contact_email"
    t.string "key_contact_phone"
    t.boolean "sender", default: false, null: false
    t.string "receiver_name"
    t.string "receiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "npi"
    t.string "ein"
    t.string "trace_id", limit: 10
  end

  create_table "data_sources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ed_ip_visit_files", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "file"
    t.string "content"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.index ["created_at"], name: "index_ed_ip_visit_files_on_created_at"
    t.index ["deleted_at"], name: "index_ed_ip_visit_files_on_deleted_at"
    t.index ["updated_at"], name: "index_ed_ip_visit_files_on_updated_at"
    t.index ["user_id"], name: "index_ed_ip_visit_files_on_user_id"
  end

  create_table "ed_ip_visits", id: :serial, force: :cascade do |t|
    t.integer "ed_ip_visit_file_id", null: false
    t.string "medicaid_id"
    t.string "last_name"
    t.string "first_name"
    t.string "gender"
    t.date "dob"
    t.date "admit_date"
    t.date "discharge_date"
    t.string "discharge_disposition"
    t.string "encounter_major_class"
    t.string "visit_type"
    t.string "encounter_facility"
    t.string "chief_complaint"
    t.string "diagnosis"
    t.string "attending_physician"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["created_at"], name: "index_ed_ip_visits_on_created_at"
    t.index ["deleted_at"], name: "index_ed_ip_visits_on_deleted_at"
    t.index ["ed_ip_visit_file_id"], name: "index_ed_ip_visits_on_ed_ip_visit_file_id"
    t.index ["medicaid_id"], name: "index_ed_ip_visits_on_medicaid_id"
    t.index ["updated_at"], name: "index_ed_ip_visits_on_updated_at"
  end

  create_table "eligibility_inquiries", id: :serial, force: :cascade do |t|
    t.date "service_date", null: false
    t.string "inquiry"
    t.string "result"
    t.integer "isa_control_number", null: false
    t.integer "group_control_number", null: false
    t.integer "transaction_control_number", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "internal", default: false
    t.integer "batch_id"
    t.boolean "has_batch", default: false
    t.index ["batch_id"], name: "index_eligibility_inquiries_on_batch_id"
  end

  create_table "eligibility_responses", id: :serial, force: :cascade do |t|
    t.integer "eligibility_inquiry_id"
    t.string "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "num_eligible"
    t.integer "num_ineligible"
    t.integer "user_id"
    t.string "original_filename"
    t.datetime "deleted_at"
    t.integer "num_errors"
  end

  create_table "encounter_records", force: :cascade do |t|
    t.bigint "encounter_report_id"
    t.string "medicaid_id"
    t.date "date"
    t.string "provider_name"
    t.boolean "contact_reached"
    t.string "mode_of_contact"
    t.date "dob"
    t.string "gender"
    t.string "race"
    t.string "ethnicity"
    t.string "veteran_status"
    t.string "housing_status"
    t.string "source"
    t.string "encounter_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_report_id"], name: "index_encounter_records_on_encounter_report_id"
  end

  create_table "encounter_reports", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_encounter_reports_on_user_id"
  end

  create_table "enrollment_rosters", id: :serial, force: :cascade do |t|
    t.integer "roster_file_id"
    t.string "member_id"
    t.string "performance_year"
    t.string "region"
    t.string "service_area"
    t.string "aco_pidsl"
    t.string "aco_name"
    t.string "pcc_pidsl"
    t.string "pcc_name"
    t.string "pcc_npi"
    t.string "pcc_taxid"
    t.string "mco_pidsl"
    t.string "mco_name"
    t.string "enrolled_flag"
    t.string "enroll_type"
    t.string "enroll_stop_reason"
    t.string "rating_category_char_cd"
    t.string "ind_dds"
    t.string "ind_dmh"
    t.string "ind_dta"
    t.string "ind_dss"
    t.string "cde_hcb_waiver"
    t.string "cde_waiver_category"
    t.date "span_start_date"
    t.date "span_end_date"
    t.integer "span_mem_days"
    t.string "cp_prov_type"
    t.string "cp_plan_type"
    t.string "cp_pidsl"
    t.string "cp_prov_name"
    t.date "cp_enroll_dt"
    t.date "cp_disenroll_dt"
    t.string "cp_start_rsn"
    t.string "cp_stop_rsn"
    t.string "ind_medicare_a"
    t.string "ind_medicare_b"
    t.string "tpl_coverage_cat"
  end

  create_table "enrollments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "content"
    t.string "original_filename"
    t.string "status"
    t.integer "new_patients"
    t.integer "returning_patients"
    t.integer "disenrolled_patients"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epic_careplans", id: :serial, force: :cascade do |t|
    t.string "patient_id"
    t.string "id_in_source"
    t.string "encounter_id"
    t.string "encounter_type"
    t.datetime "careplan_updated_at"
    t.string "staff"
    t.text "part_1"
    t.text "part_2"
    t.text "part_3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_source_id"
  end

  create_table "epic_case_note_qualifying_activities", id: :serial, force: :cascade do |t|
    t.string "patient_id"
    t.string "id_in_source"
    t.string "epic_case_note_source_id"
    t.string "encounter_type"
    t.datetime "update_date"
    t.string "staff"
    t.text "part_1"
    t.text "part_2"
    t.text "part_3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_source_id"
  end

  create_table "epic_case_notes", id: :serial, force: :cascade do |t|
    t.string "patient_id", null: false
    t.string "id_in_source", null: false
    t.datetime "contact_date"
    t.string "closed"
    t.string "encounter_type"
    t.string "provider_name"
    t.string "location"
    t.string "chief_complaint_1"
    t.string "chief_complaint_1_comment"
    t.string "chief_complaint_2"
    t.string "chief_complaint_2_comment"
    t.string "dx_1_icd10"
    t.string "dx_1_name"
    t.string "dx_2_icd10"
    t.string "dx_2_name"
    t.string "homeless_status"
    t.integer "data_source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_epic_case_notes_on_patient_id"
  end

  create_table "epic_chas", id: :serial, force: :cascade do |t|
    t.string "patient_id"
    t.string "id_in_source"
    t.string "encounter_id"
    t.string "encounter_type"
    t.datetime "cha_updated_at"
    t.string "staff"
    t.string "provider_type"
    t.string "reviewer_name"
    t.string "reviewer_provider_type"
    t.text "part_1"
    t.text "part_2"
    t.text "part_3"
    t.text "part_4"
    t.text "part_5"
    t.text "part_6"
    t.text "part_7"
    t.text "part_8"
    t.text "part_9"
    t.text "part_10"
    t.text "part_11"
    t.text "part_12"
    t.text "part_13"
    t.text "part_14"
    t.text "part_15"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_source_id"
  end

  create_table "epic_goals", id: :serial, force: :cascade do |t|
    t.string "patient_id", null: false
    t.string "entered_by"
    t.string "title"
    t.string "contents"
    t.string "id_in_source"
    t.string "received_valid_complaint"
    t.datetime "goal_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "data_source_id", default: 6, null: false
    t.index ["patient_id"], name: "index_epic_goals_on_patient_id"
  end

  create_table "epic_patients", id: :serial, force: :cascade do |t|
    t.string "id_in_source", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.text "aliases"
    t.date "birthdate"
    t.text "allergy_list"
    t.string "primary_care_physician"
    t.string "transgender"
    t.string "race"
    t.string "ethnicity"
    t.string "veteran_status"
    t.string "ssn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gender"
    t.datetime "consent_revoked"
    t.string "medicaid_id"
    t.string "housing_status"
    t.datetime "housing_status_timestamp"
    t.boolean "pilot", default: false, null: false
    t.integer "data_source_id", default: 6, null: false
    t.datetime "deleted_at"
    t.date "death_date"
  end

  create_table "epic_qualifying_activities", id: :serial, force: :cascade do |t|
    t.string "patient_id", null: false
    t.string "id_in_source", null: false
    t.string "patient_encounter_id"
    t.string "entered_by"
    t.string "role"
    t.date "date_of_activity"
    t.string "activity"
    t.string "mode"
    t.string "reached"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_source_id"
  end

  create_table "epic_ssms", id: :serial, force: :cascade do |t|
    t.string "patient_id"
    t.string "id_in_source"
    t.string "encounter_id"
    t.string "encounter_type"
    t.datetime "ssm_updated_at"
    t.string "staff"
    t.text "part_1"
    t.text "part_2"
    t.text "part_3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_source_id"
  end

  create_table "epic_team_members", id: :serial, force: :cascade do |t|
    t.string "patient_id", null: false
    t.string "id_in_source"
    t.string "name"
    t.string "pcp_type"
    t.string "relationship"
    t.string "email"
    t.string "phone"
    t.datetime "processed"
    t.integer "data_source_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment", id: :serial, force: :cascade do |t|
    t.string "item"
    t.string "provider"
    t.integer "quantity"
    t.date "effective_date"
    t.string "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "patient_id"
    t.string "status"
  end

  create_table "health_files", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.string "file"
    t.string "content_type"
    t.binary "content"
    t.integer "client_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "note"
    t.string "name"
    t.float "size"
    t.integer "parent_id"
    t.index ["type"], name: "index_health_files_on_type"
  end

  create_table "health_goals", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "type"
    t.integer "number"
    t.string "name"
    t.string "associated_dx"
    t.string "barriers"
    t.string "provider_plan"
    t.string "case_manager_plan"
    t.string "rn_plan"
    t.string "bh_plan"
    t.string "other_plan"
    t.integer "confidence"
    t.string "az_housing"
    t.string "az_income"
    t.string "az_non_cash_benefits"
    t.string "az_disabilities"
    t.string "az_food"
    t.string "az_employment"
    t.string "az_training"
    t.string "az_transportation"
    t.string "az_life_skills"
    t.string "az_health_care_coverage"
    t.string "az_physical_health"
    t.string "az_mental_health"
    t.string "az_substance_use"
    t.string "az_criminal_justice"
    t.string "az_legal"
    t.string "az_safety"
    t.string "az_risk"
    t.string "az_family"
    t.string "az_community"
    t.string "az_time_management"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "goal_details"
    t.text "problem"
    t.date "start_date"
    t.text "intervention"
    t.string "status"
    t.integer "responsible_team_member_id"
    t.integer "patient_id"
    t.index ["patient_id"], name: "index_health_goals_on_patient_id"
    t.index ["user_id"], name: "index_health_goals_on_user_id"
  end

  create_table "medications", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.date "ordered_date"
    t.text "name"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_in_source"
    t.string "patient_id"
    t.integer "data_source_id", default: 6, null: false
  end

  create_table "member_status_report_patients", id: :serial, force: :cascade do |t|
    t.integer "member_status_report_id"
    t.string "medicaid_id", limit: 12
    t.string "member_first_name", limit: 100
    t.string "member_last_name", limit: 100
    t.string "member_middle_initial", limit: 1
    t.string "member_suffix", limit: 20
    t.date "member_date_of_birth"
    t.string "member_sex", limit: 1
    t.string "aco_mco_name", limit: 100
    t.string "aco_mco_pid", limit: 9
    t.string "aco_mco_sl", limit: 10
    t.string "cp_name_official", limit: 100
    t.string "cp_pid", limit: 9
    t.string "cp_sl", limit: 10
    t.string "cp_outreach_status", limit: 30
    t.date "cp_last_contact_date"
    t.string "cp_last_contact_face", limit: 1
    t.string "cp_contact_face"
    t.date "cp_participation_form_date"
    t.date "cp_care_plan_sent_pcp_date"
    t.date "cp_care_plan_returned_pcp_date"
    t.string "key_contact_name_first", limit: 100
    t.string "key_contact_name_last", limit: 100
    t.string "key_contact_phone", limit: 10
    t.string "key_contact_email", limit: 60
    t.string "care_coordinator_first_name", limit: 100
    t.string "care_coordinator_last_name", limit: 100
    t.string "care_coordinator_phone", limit: 10
    t.string "care_coordinator_email", limit: 60
    t.string "record_status", limit: 1
    t.date "record_update_date"
    t.date "export_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_member_status_report_patients_on_deleted_at"
  end

  create_table "member_status_reports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "job_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "sender", limit: 100
    t.integer "sent_row_num"
    t.integer "sent_column_num"
    t.datetime "sent_export_time_stamp"
    t.string "receiver"
    t.date "report_start_date"
    t.date "report_end_date"
    t.string "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_member_status_reports_on_deleted_at"
  end

  create_table "participation_forms", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.date "signature_on"
    t.integer "case_manager_id"
    t.integer "reviewed_by_id"
    t.string "location"
    t.integer "health_file_id"
    t.datetime "reviewed_at"
    t.string "reviewer"
    t.index ["case_manager_id"], name: "index_participation_forms_on_case_manager_id"
    t.index ["health_file_id"], name: "index_participation_forms_on_health_file_id"
    t.index ["patient_id"], name: "index_participation_forms_on_patient_id"
    t.index ["reviewed_by_id"], name: "index_participation_forms_on_reviewed_by_id"
  end

  create_table "patient_referral_imports", id: :serial, force: :cascade do |t|
    t.string "file_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patient_referrals", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "birthdate"
    t.string "ssn"
    t.string "medicaid_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "agency_id"
    t.boolean "rejected", default: false, null: false
    t.integer "rejected_reason", default: 0, null: false
    t.integer "patient_id"
    t.integer "accountable_care_organization_id"
    t.string "middle_initial"
    t.string "suffix"
    t.string "gender"
    t.string "aco_name"
    t.integer "aco_mco_pid"
    t.string "aco_mco_sl"
    t.string "health_plan_id"
    t.string "cp_assignment_plan"
    t.string "cp_name_dsrip"
    t.string "cp_name_official"
    t.integer "cp_pid"
    t.string "cp_sl"
    t.date "enrollment_start_date"
    t.string "start_reason_description"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip"
    t.string "address_zip_plus_4"
    t.string "email"
    t.string "phone_cell"
    t.string "phone_day"
    t.string "phone_night"
    t.string "primary_language"
    t.string "primary_diagnosis"
    t.string "secondary_diagnosis"
    t.string "pcp_last_name"
    t.string "pcp_first_name"
    t.string "pcp_npi"
    t.string "pcp_address_line_1"
    t.string "pcp_address_line_2"
    t.string "pcp_address_city"
    t.string "pcp_address_state"
    t.string "pcp_address_zip"
    t.string "pcp_address_phone"
    t.string "dmh"
    t.string "dds"
    t.string "eoea"
    t.string "ed_visits"
    t.string "snf_discharge"
    t.string "identification"
    t.string "record_status"
    t.date "record_updated_on"
    t.date "exported_on"
    t.boolean "removal_acknowledged", default: false
    t.datetime "effective_date"
    t.date "disenrollment_date"
    t.string "stop_reason_description"
    t.date "pending_disenrollment_date"
  end

  create_table "patients", id: :serial, force: :cascade do |t|
    t.string "id_in_source", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.text "aliases"
    t.date "birthdate"
    t.text "allergy_list"
    t.string "primary_care_physician"
    t.string "transgender"
    t.string "race"
    t.string "ethnicity"
    t.string "veteran_status"
    t.string "ssn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_id"
    t.string "gender"
    t.datetime "consent_revoked"
    t.string "medicaid_id"
    t.string "housing_status"
    t.datetime "housing_status_timestamp"
    t.boolean "pilot", default: false, null: false
    t.integer "data_source_id", default: 6, null: false
    t.date "engagement_date"
    t.integer "care_coordinator_id"
    t.datetime "deleted_at"
    t.date "death_date"
    t.string "coverage_level"
    t.date "coverage_inquiry_date"
    t.datetime "eligibility_notification"
    t.string "aco_name"
    t.string "previous_aco_name"
    t.boolean "invalid_id", default: false
    t.index ["client_id"], name: "patients_client_id_constraint", unique: true, where: "(deleted_at IS NULL)"
    t.index ["medicaid_id"], name: "index_patients_on_medicaid_id"
  end

  create_table "premium_payments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.string "original_filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.jsonb "converted_content"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["deleted_at"], name: "index_premium_payments_on_deleted_at"
  end

  create_table "problems", id: :serial, force: :cascade do |t|
    t.date "onset_date"
    t.date "last_assessed"
    t.text "name"
    t.text "comment"
    t.string "icd10_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_in_source"
    t.string "patient_id"
    t.integer "data_source_id", default: 6, null: false
  end

  create_table "qualifying_activities", id: :serial, force: :cascade do |t|
    t.string "mode_of_contact"
    t.string "mode_of_contact_other"
    t.string "reached_client"
    t.string "reached_client_collateral_contact"
    t.string "activity"
    t.string "source_type"
    t.integer "source_id"
    t.datetime "claim_submitted_on"
    t.date "date_of_activity"
    t.integer "user_id"
    t.string "user_full_name"
    t.string "follow_up"
    t.integer "patient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "claim_id"
    t.boolean "force_payable", default: false, null: false
    t.boolean "naturally_payable", default: false, null: false
    t.datetime "sent_at"
    t.integer "duplicate_id"
    t.string "epic_source_id"
    t.index ["claim_id"], name: "index_qualifying_activities_on_claim_id"
    t.index ["date_of_activity"], name: "index_qualifying_activities_on_date_of_activity"
    t.index ["patient_id"], name: "index_qualifying_activities_on_patient_id"
    t.index ["source_id"], name: "index_qualifying_activities_on_source_id"
    t.index ["source_type"], name: "index_qualifying_activities_on_source_type"
  end

  create_table "release_forms", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "user_id"
    t.date "signature_on"
    t.string "file_location"
    t.integer "health_file_id"
    t.integer "reviewed_by_id"
    t.datetime "reviewed_at"
    t.string "reviewer"
    t.index ["health_file_id"], name: "index_release_forms_on_health_file_id"
    t.index ["patient_id"], name: "index_release_forms_on_patient_id"
    t.index ["reviewed_by_id"], name: "index_release_forms_on_reviewed_by_id"
    t.index ["user_id"], name: "index_release_forms_on_user_id"
  end

  create_table "rosters", id: :serial, force: :cascade do |t|
    t.integer "roster_file_id"
    t.string "member_id"
    t.string "nam_first"
    t.string "nam_last"
    t.string "cp_pidsl"
    t.string "cp_name"
    t.string "aco_pidsl"
    t.string "aco_name"
    t.string "mco_pidsl"
    t.string "mco_name"
    t.string "sex"
    t.date "date_of_birth"
    t.string "mailing_address_1"
    t.string "mailing_address_2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_zip"
    t.string "residential_address_1"
    t.string "residential_address_2"
    t.string "residential_city"
    t.string "residential_state"
    t.string "residential_zip"
    t.string "race"
    t.string "phone_number"
    t.string "primary_language_s"
    t.string "primary_language_w"
    t.string "sdh_nss7_score"
    t.string "sdh_homelessness"
    t.string "sdh_addresses_flag"
    t.string "sdh_other_disabled"
    t.string "sdh_spmi"
    t.string "raw_risk_score"
    t.string "normalized_risk_score"
    t.string "raw_dxcg_risk_score"
    t.date "last_office_visit"
    t.date "last_ed_visit"
    t.date "last_ip_visit"
    t.string "enrolled_flag"
    t.string "enrollment_status"
    t.date "cp_claim_dt"
    t.string "qualifying_hcpcs"
    t.string "qualifying_hcpcs_nm"
    t.string "qualifying_dsc"
    t.string "email"
    t.string "head_of_household"
  end

  create_table "sdh_case_management_notes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "patient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "topics"
    t.string "title"
    t.integer "total_time_spent_in_minutes"
    t.datetime "date_of_contact"
    t.string "place_of_contact"
    t.string "housing_status"
    t.string "place_of_contact_other"
    t.string "housing_status_other"
    t.datetime "housing_placement_date"
    t.text "client_action"
    t.text "notes_from_encounter"
    t.string "client_phone_number"
    t.datetime "completed_on"
    t.integer "health_file_id"
    t.string "client_action_medication_reconciliation_clinician"
    t.index ["health_file_id"], name: "index_sdh_case_management_notes_on_health_file_id"
  end

  create_table "self_sufficiency_matrix_forms", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "user_id"
    t.string "point_completed"
    t.integer "housing_score"
    t.text "housing_notes"
    t.integer "income_score"
    t.text "income_notes"
    t.integer "benefits_score"
    t.text "benefits_notes"
    t.integer "disabilities_score"
    t.text "disabilities_notes"
    t.integer "food_score"
    t.text "food_notes"
    t.integer "employment_score"
    t.text "employment_notes"
    t.integer "education_score"
    t.text "education_notes"
    t.integer "mobility_score"
    t.text "mobility_notes"
    t.integer "life_score"
    t.text "life_notes"
    t.integer "healthcare_score"
    t.text "healthcare_notes"
    t.integer "physical_health_score"
    t.text "physical_health_notes"
    t.integer "mental_health_score"
    t.text "mental_health_notes"
    t.integer "substance_abuse_score"
    t.text "substance_abuse_notes"
    t.integer "criminal_score"
    t.text "criminal_notes"
    t.integer "legal_score"
    t.text "legal_notes"
    t.integer "safety_score"
    t.text "safety_notes"
    t.integer "risk_score"
    t.text "risk_notes"
    t.integer "family_score"
    t.text "family_notes"
    t.integer "community_score"
    t.text "community_notes"
    t.integer "time_score"
    t.text "time_notes"
    t.datetime "completed_at"
    t.string "collection_location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "health_file_id"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "service_type"
    t.string "provider"
    t.string "hours"
    t.string "days"
    t.date "date_requested"
    t.date "effective_date"
    t.date "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "patient_id"
    t.string "status"
  end

  create_table "signable_documents", id: :serial, force: :cascade do |t|
    t.integer "signable_id", null: false
    t.string "signable_type", null: false
    t.boolean "primary", default: true, null: false
    t.integer "user_id", null: false
    t.jsonb "hs_initial_request"
    t.jsonb "hs_initial_response"
    t.datetime "hs_initial_response_at"
    t.jsonb "hs_last_response"
    t.datetime "hs_last_response_at"
    t.string "hs_subject", default: "Signature Request", null: false
    t.string "hs_title", default: "Signature Request", null: false
    t.text "hs_message", default: "You've been asked to sign a document."
    t.jsonb "signers", default: [], null: false
    t.jsonb "signed_by", default: [], null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.integer "health_file_id"
    t.index ["signable_id", "signable_type"], name: "index_signable_documents_on_signable_id_and_signable_type"
  end

  create_table "signature_requests", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "patient_id", null: false
    t.integer "careplan_id", null: false
    t.string "to_email", null: false
    t.string "to_name", null: false
    t.string "requestor_email", null: false
    t.string "requestor_name", null: false
    t.datetime "expires_at", null: false
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "signable_document_id"
    t.index ["careplan_id"], name: "index_signature_requests_on_careplan_id"
    t.index ["deleted_at"], name: "index_signature_requests_on_deleted_at"
    t.index ["patient_id"], name: "index_signature_requests_on_patient_id"
    t.index ["type"], name: "index_signature_requests_on_type"
  end

  create_table "soap_configs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "user"
    t.string "encrypted_pass"
    t.string "encrypted_pass_iv"
    t.string "sender"
    t.string "receiver"
    t.string "test_url"
    t.string "production_url"
  end

  create_table "ssm_exports", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.jsonb "options"
    t.jsonb "headers"
    t.jsonb "rows"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["created_at"], name: "index_ssm_exports_on_created_at"
    t.index ["updated_at"], name: "index_ssm_exports_on_updated_at"
    t.index ["user_id"], name: "index_ssm_exports_on_user_id"
  end

  create_table "team_members", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "organization"
    t.string "title"
    t.date "last_contact"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "phone"
    t.integer "patient_id"
    t.index ["patient_id"], name: "index_team_members_on_patient_id"
    t.index ["type"], name: "index_team_members_on_type"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "careplan_id"
    t.index ["careplan_id"], name: "index_teams_on_careplan_id"
  end

  create_table "transaction_acknowledgements", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.string "original_filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_transaction_acknowledgements_on_deleted_at"
  end

  create_table "user_care_coordinators", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "care_coordinator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.integer "user_id"
    t.string "session_id"
    t.string "request_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "visits", id: :serial, force: :cascade do |t|
    t.string "department"
    t.string "visit_type"
    t.string "provider"
    t.string "id_in_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "patient_id"
    t.datetime "date_of_service"
    t.integer "data_source_id", default: 6, null: false
  end

  add_foreign_key "comprehensive_health_assessments", "health_files"
  add_foreign_key "comprehensive_health_assessments", "patients"
  add_foreign_key "health_goals", "patients"
  add_foreign_key "participation_forms", "health_files"
  add_foreign_key "release_forms", "health_files"
  add_foreign_key "sdh_case_management_notes", "health_files"
  add_foreign_key "team_members", "patients"
end
