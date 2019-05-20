# A reporting table to power the enrollment related answers for project data quality reports.

# Some notes on completeness from the HUD Glossary

# Order for checking: Doesn't know/refused, then missing.
# Rules
# • Within each row, the column categories are mutually exclusive; records that meet more than one of the criteria described below should be counted in the column for the first match.
# • Column B Row 2 – count of clients where [Name Data Quality] = 8 or 9.
# • Column C Row 2 – count of clients where [First Name] OR [Last Name] is missing.
# • Column D Row 2 – [Name Data Quality] = 2
# • Column B Row 3 – count of clients where [SSN Data Quality] = 8 or 9.
# • Column C Row 3 – count of clients where [SSN] is missing.
# • Column D Row 3 – count of clients where [SSN Data Quality] = 2 OR [SSN] does not conform to Social
# Security Administration rules for a valid SSN shown below.
# o Cannot contain a non-numeric character.
# o Must be 9 digits long.
# o First three digits cannot be “000,” “666,” or in the 900 series. o The second group / 5th and 6th digits cannot be “00”.
# o The third group / last four digits cannot be “0000”.
# o There cannot be repetitive (e.g. “333333333”) or sequential (e.g. “345678901” “987654321”)
# numbers for all 9 digits.
# • Column B Row 4 – count of clients where [DOB Data Quality] = 8 or 9.
# • Column C Row 4 – count of clients where [DOB] is missing.
# • Column D Row 4 – count of clients where [DOB Data Quality] = 2 OR where [DOB] is any one of the values
# listed below
# o Priorto1/1/1915.
# o After the [date created] for the record.
# o For heads of household and adults only: Equal to or after the [project start date]. This test
# purposely excludes child household members including those who may be newborns.
# • Column B Row 5, 6, 7 – count of clients where [Race] [Ethnicity] [Gender] respectively = 8 or 9. For [Race],
# include records with an 8 or 9 indicated even if there is also a value of 1, 2, 3, 4 or 5 in the same field.
# • Column C Row 5, 6, 7 – count of clients where [Race] [Ethnicity] [Gender] respectively is missing.
# • Column E Rows 2 through 7 – [total] = the unique count of clients reported in columns B, C or D, i.e. report
# each record only once per person if the field fails any one of the data quality checks. Divide the [total] by
# the total number of people indicated in the validations table.
# • Column E Row 8 – [total] = the unique count of clients reported in columns B, C or D / rows 2 through 7.
# Again, report each record only once per person even if there are multiple data quality issues in multiple fields.

# • Column B Row 2: count of adults where [veteran status] = 8, 9, missing OR ([veteran status] = 1 and [Age] < 18).
# • Column B Row 3: count of clients where:
# o [Project start date] < [project exit date] for an earlier project start. This detects overlapping project
# stays by the same client in the same project.
# • Column B Row 4: count of all clients where any one of the following are true:
# o [Relationship to Head of Household] is missing or has a value that is not between 1 and 5. OR
# o Thereisnohouseholdmemberforthegroupofclientswiththesame[HouseholdID]wherethe
# [Relationship to Head of Household] = Self (1). I.e. report every household member without an
# identified head of household for the [Household ID]. OR
# o More than one client for the [Household ID] has a [Relationship to Head of Household] = Self. I.e.
# report every household member in households where multiple heads of household exist. • Column B Row 5: count of heads of household where:
# o There is no record of [client location] for the project start with a [data collection stage] of project start (1). OR
# o The [Continuum of Care Code] for the client location record does not match a valid HUD-defined Continuum of Care Code.
# • Column B Row 6: count of clients where ([disabling condition] = 8, 9, missing) OR ([disabling condition] = 0 AND there is at least one special need where “substantially impairs ability to live independently” = 1)

# 1. Column B Row 2 – count the number of leavers where [Destination] = 8, 9, 30, or missing.
# 2. Column B Row 3 – count the number of adults and heads of household active in the report date range
# where any one of the following are true:
#  22 | P a g e
#                a. [income and sources] at start is completely missing.
# b. There is no record of [income and sources] with an [information date] equal to [project start date]
# and a [data collection stage] of project start (1).
# c. [data collection stage] for [income and sources] = 1 AND [income from any source] = 8, 9, or missing.
# d. [data collection stage] for [income and sources] = 1 AND [income from any source] = 0 AND there
# are identified income sources.
# e. [data collection stage] for [income and sources] = 1 AND [income from any source] = 1 AND there
# are no identified income sources.
# 3. Column B Row 4 – count the number of adults and heads of household stayers active in the report date
# range where the head of household has a project stay of >= 365 days as of the [report end date] AND where any one of the following are true:
# a. There is no record of [income and sources] with an [information date] within 30 days of the anniversary date and a [data collection stage] of annual assessment (5).
# b. [information date] is within 30 days of the anniversary date AND [data collection stage] for [income and sources] = 5 AND [income from any source] = 8, 9, or missing.
# c. [information date] is within 30 days of the anniversary date AND [data collection stage] for [income and sources] = 5 AND [income from any source] = 0 AND there are identified income sources.
# d. [information date] is within 30 days of the anniversary date AND [data collection stage] for [income and sources] = 5 AND [income from any source] = 1 AND there are no identified income sources.
# 4. Column B Row 5 – count the number of adult and head of household leavers where any one of the following are true:
# a. There is no record of [income and sources] with an [information date] equal to [project exit date] and a [data collection stage] of project exit (3).
# b. [data collection stage] for [income and sources] = 3 AND [income from any source] = 8, 9, or missing.
# c. [income from any source] = 0 AND there are identified income sources.
# d. [income from any source] = 1 AND there are no identified income sources.

module Reporting::DataQualityReports
  class Enrollment < ReportingBase
    include ArelHelper

    COMPLETE = [1, 2]
    REFUSED = [8, 9]
    YES_NO = [0,1]
    VALID_GENDERS = [0,1,2,3,4]

    self.table_name = :warehouse_data_quality_report_enrollments

    scope :enrolled, -> do
      where enrolled: true
    end

    scope :stayer, -> do
      where exited: false
    end

    scope :leaver, -> do
      where exited: true
    end

    scope :entered, -> do
      where entered: true
    end

    scope :adult, -> do
      where adult: true
    end

    scope :head_of_household, -> do
      where head_of_household: true
    end


    def is_adult? date
      age = calculate_age date
      age.present? && age > 18
    end

    def calculate_age date
      GrdaWarehouse::Hud::Client.age date: date, dob: dob
    end

    def is_stayer? report_end:, exit_date:
      return true if exit_date.blank?
      exit_date > report_end
    end

    def is_leaver? report_end:, exit_date:
      exit_date.present? && exit_date <= report_end
    end

    # Blanks should not be allowed according to the spec
    def is_head_of_household? enrollment
      enrollment.RelationshipToHoH.blank? || enrollment.RelationshipToHoH.to_s == '1'
    end

    def calculate_days_to_add_entry_date enrollment
      enrollment.DateCreated - enrollment.EntryDate
    end

    def calculate_days_to_add_exit_date exit_record
      if exit_record.blank? || exit_record.ExitDate.blank?
        nil
      else
        exit_record.DateCreated - enrollment.ExitDate
      end
    end

    def calculate_dob_after_entry_date
      dob.present? && dob > entry_date
    end

    def is_active? project:, service_dates:, report_start:, report_end:
      return true unless project.bed_night_tracking?
      ((report_start..report_end).to_a & service_dates).any?
    end

    def calculate_household_type household_ids:
      if household_ids.count(household_id) > 1
         :family
       else
        :individual
      end
    end

    def calculate_most_recent_service_within_range project:, service_dates:, report_start:, report_end:, exit_date:
      if ! project.bed_night_tracking?
        [report_end, exit_date].min
      else
        ((report_start..report_end).to_a & service_dates).max
      end
    end

    def calculate_service_witin_last_30_days project:, service_dates:, exit_date:, report_end:
      if ! project.bed_night_tracking?
        true
      else
        if exit_date.present?
          ((exit_date - 30.days)..exit_date)
        else
          ((report_end - 30.days)..report_end)
        end
        (range.to_a & service_dates).any?
      end
    end

    def calculate_service_after_exit project:, service_dates:, exit_date:
      if ! project.bed_night_tracking? || exit_date.blank?
        false
      else
        service_dates.max > exit_date
      end
    end

    # NOTE: days served between start and exit, or if no exit and the
    # project is entry-exit, between start and report_end
    def calculate_days_of_service project:, service_dates:, entry_date:, exit_date:,  report_end:
      if project.bed_night_tracking?
        service_dates.uniq.count
      else
        if exit_date.present?
          (exit_date - entry_date).to_i
        else
          (report_end - entry_date).to_i
        end
      end
    end

    def calculate_name_complete first_name:, last_name:, name_quality:
      name_quality.in?(COMPLETE) && first_name.present? && last_name.present?
    end

    def calculate_name_refused name_quality:
      name_quality.in?(REFUSED)
    end

    def calculate_name_missing first_name:, last_name:
      first_name.blank? || last_name.blank?
    end

    def calculate_ssn_complete ssn:, ssn_quality:
      ssn_quality.in?(COMPLETE) && ssn.present?
    end

    def calculate_ssn_refused ssn_quality:
      ssn_quality.in?(REFUSED)
    end

    def calculate_ssn_missing ssn:
      ssn.blank? || ! ::HUD.valid_social?(ssn)
    end

    def calculate_dob_complete dob:, dob_quality:
      dob_quality.in?(COMPLETE) && dob.present?
    end

    def calculate_dob_refused dob_quality:
      dob_quality.in?(REFUSED)
    end

    def calculate_dob_missing dob:, dob_quality:, head_of_household:, entry_date:, enrollment_created_date:
      missing = false
      missing = true if dob.blank?
      missing = true if dob_quality == 2
      missing = true if dob.present? && dob < '1915-01-01'.to_date
      missing = true if dob.present? && dob > enrollment_created_date
      missing = true if (is_adult?(Date.today) || head_of_household) && dob.present? && dob >= entry_date

      return missing
    end

    def calculate_gender_complete gender:
      gender.present? && gender.in?(VALID_GENDERS)
    end

    def calculate_gender_refused gender:
      gender.in?(REFUSED)
    end

    def calculate_gender_missing gender:
      gender.blank?
    end

    def calculate_veteran_complete veteran:
      if is_adult?(Date.today)
        veteran.present? && veteran.in?(YES_NO)
      else
        veteran != 1
      end
    end

    def calculate_veteran_refused veteran:
      return false unless is_adult?(Date.today)
      veteran.in?(REFUSED)
    end

    def calculate_veteran_missing veteran:
      return false unless is_adult?(Date.today)
      veteran.blank?
    end

    def calculate_ethnicity_complete ethnicity:
      ethnicity.present? && ethnicity.in?(YES_NO)
    end

    def calculate_ethnicity_refused ethnicity:
      ethnicity.in?(REFUSED)
    end

    def calculate_ethnicity_missing ethnicity:
      ethnicity.blank?
    end

    # because of the complexity for race, we'll just confirm it is not missing or refused
    def calculate_race_complete race_none:, american_indian_or_ak_native:, asian:, black_or_african_american:, native_hi_or_other_pacific_islander:, white:
      ! calculate_race_refused(race_none: race_none) && ! calculate_race_missing(
          race_none: race_none,
          american_indian_or_ak_native: american_indian_or_ak_native,
          asian: asian,
          black_or_african_american: black_or_african_american,
          native_hi_or_other_pacific_islander: native_hi_or_other_pacific_islander,
          white: white
        )
    end

    def calculate_race_refused race_none:
      race_none.in?(REFUSED)
    end

    # all blank
    def calculate_race_missing race_none:, american_indian_or_ak_native:, asian:, black_or_african_american:, native_hi_or_other_pacific_islander:, white:
      race_none.blank? &&
      american_indian_or_ak_native.blank? &&
      asian.blank? &&
      black_or_african_american.blank? &&
      native_hi_or_other_pacific_islander.blank? &&
      white.blank?
    end

    # This uses 3.8 Disabling condition, NOT the disability table, HMIS should
    # keep this in sync with 4.5 - 4.10, with the exception of indefinite and impairs
    def calculate_disabling_condition_complete disabling_condition:, indefinite_and_impairs_all:
      return true unless is_adult?(Date.today)
      ! calculate_disabling_condition_refused(disabling_condition: disabling_condition)&& ! calculate_disabling_condition_missing(
          disabling_condition: disabling_condition,
          indefinite_and_impairs_all: indefinite_and_impairs_all
        )
    end

    def calculate_disabling_condition_refused disabling_condition:
      return false unless is_adult?(Date.today)
      disabling_condition.in?(REFUSED)
    end

    def calculate_disabling_condition_missing disabling_condition:, indefinite_and_impairs_all:
      return false unless is_adult?(Date.today)
      disabling_condition.blank? || disabling_condition == 0 && indefinite_and_impairs_all.any?(1)
    end

    def calculate_prior_living_situation_complete prior_living_situation:, head_of_household:
      return true unless is_adult?(Date.today) || head_of_household
      ! calculate_prior_living_situation_refused(prior_living_situation: prior_living_situation) && ! calculate_prior_living_situation_missing(prior_living_situation: prior_living_situation)
    end

    def calculate_prior_living_situation_refused prior_living_situation:,
      return false unless is_adult?(Date.today) || head_of_household
      prior_living_situation.in?(REFUSED)
    end

    def calculate_prior_living_situation_missing prior_living_situation:,
      return false unless is_adult?(Date.today) || head_of_household
      prior_living_situation.blank?
    end

    def calculate_income_at_entry_complete income_at_entry:
      return true unless is_adult?(Date.today) || head_of_household
      ! calculate_income_at_entry_refused(income_at_entry: income_at_entry) && ! calculate_income_at_entry_missing(income_at_entry: income_at_entry)
    end

    def calculate_income_at_entry_refused income_at_entry:
      return false unless is_adult?(Date.today) || head_of_household
      income_at_entry.present? && income_at_entry.IncomeFromAnySource.in?(REFUSED)
    end

    def calculate_income_at_entry_missing income_at_entry:
      return false unless is_adult?(Date.today) || head_of_household
      income_at_entry.blank? || income_at_entry.IncomeFromAnySource.blank?
    end

    def calculate_income_at_exit_complete income_at_exit:, exit_date:, report_end:
      return true unless is_adult?(Date.today) || head_of_household
      return true if exit_date.blank? # no exit
      return true if exit_date > report_end # exit after report end
      ! calculate_income_at_exit_refused(
          income_at_exit: income_at_exit,
          exit_date: exit_date,
          report_end: report_end
        )
      && ! calculate_income_at_exit_missing(
          income_at_exit: income_at_exit,
          exit_date: exit_date,
          report_end: report_end
        )
    end

    def calculate_income_at_exit_refused income_at_exit:, exit_date:, report_end:
      return false unless is_adult?(Date.today) || head_of_household
      return false if exit_date.blank? # no exit
      return false if exit_date > report_end # exit after report end
      income_at_exit.present? && income_at_exit.IncomeFromAnySource.in?(REFUSED)
    end

    def calculate_income_at_exit_missing
      return false unless is_adult?(Date.today) || head_of_household
      return false if exit_date.blank? # no exit
      return false if exit_date > report_end # exit after report end
      income_at_exit.blank? || income_at_exit.IncomeFromAnySource.blank?
    end

    def calculate_income_at_entry income_at_entry:

    end

    def calculate_income_at_later_date incomes:

    end

    # NOTE: check PT for additional requested checks
    # heads of household enrolled > 30 days with no move-in date in PH (all PH) include in completeness and summary

  end
end