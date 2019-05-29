module Reporting::ProjectDataQualityReports::VersionFour::Display
  extend ActiveSupport::Concern
  include ActionView::Helpers
  include ActionView::Context
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  included do

    def self.length_of_stay_buckets
      {
        # '0 days' => (0..0),
        # '1 week or less' => (1..6),
        # '1 month or less' => (7..30),
        '1 month or less' => (0..30),
        #'1 to 3 months'  => (31..90),
        #'3 to 6 months' => (91..180),
        '1 to 6 months' => (31..180),
        #'6 to 9 months' => (181..271),
        #'9 to 12 months' => (272..364),
        '6 to 12 months' => (181..364),
        #'1 year to 18 months' => (365..545),
        #'18 months - 2 years' => (546..729),
        #'2 - 5 years' => (730..1825),
        #'5 years or more' => (1826..1.0/0),
        '12 months or greater' => (365..Float::INFINITY),
      }
    end

    def no_clients?
      enrollments.count.zero?
    end

    def no_issues
      'No issues'
    end

    def completeness_goal
      90
    end

    def excess_goal
      105
    end

    def mininum_completeness_threshold
      100 - completeness_goal
    end

    def timeliness_goal
      14 # days
    end

    def income_increase_goal
      75
    end

    def ph_destination_increase_goal
      60
    end

    def move_in_date_threshold
      30 # days
    end

    def enrolled_clients
      enrollments.enrolled
    end

    def enrolled_client_count
      enrolled_clients.count
    end

    def enrolled_household_heads
      enrollments.enrolled.head_of_household
    end

    def enrolled_household_count
      enrolled_household_heads.count
    end

    def active_clients
      enrolled_clients.active
    end

    def active_client_count
      active_clients.count
    end

    def active_households
      enrolled_household_heads.active
    end

    def active_household_count
      active_households.count
    end

    def entering_clients
      enrolled_clients.entered
    end

    def entering_clients_count
      entering_clients.count
    end

    def entering_households
      enrolled_household_heads.entered
    end

    def entering_households_count
      entering_households.count
    end

    def exiting_clients
      enrolled_clients.exited
    end

    def exiting_client_count
      exiting_clients.count
    end

    def exiting_households
      enrolled_household_heads.exited
    end

    def exiting_household_count
      exiting_households.count
    end

    def move_in_date_above_threshold
      enrolled_clients.ph.where(days_ph_before_move_in_date: (move_in_date_threshold..Float::INFINITY))
    end

    def should_have_income_at_annual
      enrolled_clients.adult.should_calculate_income_annual_completeness
    end

    def enrolled_adults
      enrolled_clients.adult
    end

    def exiting_adults
      enrolled_clients.exited.adult
    end

    def heads_of_households_or_adults
      a_t = Reporting::DataQualityReports::Enrollment.arel_table
      enrolled_clients.where(a_t[:head_of_household].eq(true).or(a_t[:adult].eq(true)))
    end

    def served_percentages
      @served_percentages ||= begin
        percentages = []
        enrolled = enrolled_clients.group(:project_id).select(:enrolled).count
        active = active_clients.group(:project_id).select(:active).count
        enrolled.each do |id, enrolled_count|
          active_count = active[id] || 0
          percent = (active_count / enrolled_count.to_f) * 100
          if percent < completeness_goal
            percentages << {
              project_id: id,
              project_name: projects.detect{|p| p.id == id}.ProjectName,
              label: 'Percent of enrolled clients with a service in the reporting period below acceptable threshold',
              percent: percent,
            }
          end
        end
        percentages
      end
      return @served_percentages
    end

    def describe_completeness method, as_percent: false, support_path: nil, report_keys: nil
      served_percentages = self.send(method)
      if served_percentages.any?
        served_percentages.map do |details|
          content_tag(:li) do
            concat(content_tag(:span, "#{details[:project_name]}: ")) if report_type == :project_group
            details_text = "#{details[:label]}"
            details_text << " (#{details[:percent]}%)" if details[:percent]
            details_text << " (#{details[:value].presence || 'blank'})" if details[:value]
            if support_path.present?
              concat content_tag(:a, details_text, {href: polymorphic_path(support_path, report_keys.merge(method: method)), data: {'loads-in-pjax-modal' => true}})
            else
              concat content_tag(:strong, details_text)
            end
          end
        end.join.html_safe
      else
        no_issues
      end
    end

    def bed_utilization_percentages
      @bed_utilization_percentages ||= begin
        percentages = []
        report_projects.each do |report_project|
          if report_project.average_bed_utilization < completeness_goal
            percentages << {
              project_id: report_project.project_id,
              project_name: report_project.project_name,
              label: 'Bed utilization below acceptable threshold',
              percent: report_project.average_bed_utilization,
            }
          end
        end
        percentages
      end
      return @bed_utilization_percentages
    end

    def unit_utilization_percentages
      @unit_utilization_percentages ||= begin
        percentages = []
        report_projects.each do |report_project|
          if report_project.average_unit_utilization < completeness_goal
            percentages << {
              project_id: report_project.project_id,
              project_name: report_project.project_name,
              label: 'Unit utilization below acceptable threshold',
              percent: report_project.average_unit_utilization,
            }
          end
        end
        percentages
      end
      return @unit_utilization_percentages
    end

    def project_descriptor
      @project_descriptor ||= begin
        issues = []
        report_projects.each do |report_project|
          # some of these are only valid for residential project types
          if report_project.project_type.in?(GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS)
            if report_project.bed_inventory.blank? || report_project.bed_inventory.zero?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Bed Inventory',
                value: report_project.bed_inventory,
              }
            end
            if report_project.unit_inventory.blank? || report_project.unit_inventory.zero?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Unit Inventory',
                value: report_project.unit_inventory,
              }
            end
            if report_project.coc_code.blank? || report_project.coc_code.length != 6
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing or malformed CoC Code',
                value: report_project.coc_code,
              }
            end
            if report_project.funder.blank?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Funder',
                value: report_project.funder,
              }
            end
            if report_project.geocode.blank? || report_project.geocode.length != 6
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing or malformed Geocode',
                value: report_project.geocode,
              }
            end
            if report_project.geography_type.blank?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Geography Type',
                value: report_project.geography_type,
              }
            end
            if report_project.housing_type.blank?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Housing Type',
                value: report_project.housing_type,
              }
            end
            if report_project.inventory_information_dates.blank?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Inventory Information Date',
                value: report_project.inventory_information_dates,
              }
            end
            if report_project.operating_start_date.blank?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Operation Start Date',
                value: report_project.operating_start_date,
              }
            end
            if report_project.project_type.blank?
              issues << {
                project_id: report_project.project_id,
                project_name: report_project.project_name,
                label: 'Missing Project Type',
                value: report_project.project_type,
              }
            end
          end
        end
        issues
      end
      return @project_descriptor
    end

    # return where the completeness value is < threshold
    def client_data
      @client_data ||= begin
        percentages = []

        completeness_metrics.each do |key, options|
          measure = :complete
          counts = send(options[:denominator]).group(:project_id).where("#{key}_#{measure}" => true).select("#{key}_#{measure}").count
          denominators = send(options[:denominator]).group(:project_id).count
          denominators.each do |id, denominator|
            next if denominator.zero?
            count = counts[id] || 0
            denominator = send(options[:denominator]).where(project_id: id).count

            percentage = ((count.to_f / denominator) * 100).round
            if percentage < completeness_goal
              percentages << {
                project_id: id,
                project_name: projects.detect{|p| p.id == id}.ProjectName,
                label: "Low #{measure} rate - #{key.to_s.humanize}",
                percent: percentage,
              }
            end
          end
        end
        percentages
      end
      return @client_data
    end

    def completeness_metrics
      @completeness_metrics ||= {
        name: {
          measures: [
            :missing,
            :refused,
            :not_collected,
            :partial,
          ],
          denominator: :enrolled_clients,
          label: 'Name',
        },
        ssn: {
          measures: [
            :missing,
            :refused,
            :not_collected,
            :partial,
          ],
          denominator: :enrolled_clients,
          label: 'SSN',
        },
        dob: {
          measures: [
            :missing,
            :refused,
            :not_collected,
            :partial,
          ],
          denominator: :enrolled_clients,
          label: 'DOB',
        },
        gender: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :enrolled_clients,
          label: 'Gender',
        },
        veteran: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :enrolled_adults,
          label: 'Veteran Status',
        },
        ethnicity: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :enrolled_clients,
          label: 'Ethnicity',
        },
        race: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :enrolled_clients,
          label: 'Race',
        },
        disabling_condition: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :enrolled_clients,
          label: 'Disabling Condition',
        },
        prior_living_situation: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :heads_of_households_or_adults,
          label: 'Prior Living Situation',
        },
        destination: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :exiting_clients,
          label: 'Destination',
        },
        income_at_entry: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :enrolled_adults,
          label: 'Income at Entry',
        },
        income_at_annual_assessment: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :should_have_income_at_annual,
          label: 'Income Annual Assessment',
        },
        income_at_exit: {
          measures: [
            :missing,
            :refused,
            :not_collected,
          ],
          denominator: :exiting_adults,
          label: 'Income at Exit',
        },
      }
    end

    def completeness_type_labels
      @completeness_type_labels ||= {
        complete: 'Complete',
        missing: 'Missing / Null',
        refused: "Don't Know / Refused",
        not_collected: 'Not Collected',
        partial: 'Partial',
        target: 'Target',
      }
    end

    # used to exclude some metrics from the completeness charts
    def income_chart_keys
      @income_chart_keys ||= [
        :income_at_entry,
        :income_at_annnual,
        :income_at_exit,
      ]
    end

    def timeliness
      @timeliness ||= begin
        issues = []
        time_to_enter_entry = enrolled_clients.group(:project_id).
          sum(:days_to_add_entry_date)
        time_to_enter_entry.each do |id, count|
          denominator = enrolled_clients.where(project_id: id).count
          average_timeliness = count.to_f / denominator
          if average_timeliness > timeliness_goal
            issues << {
              project_id: id,
              project_name: projects.detect{|p| p.id == id}.ProjectName,
              label: "Average time to enter exceeds acceptable threshold",
              value: average_timeliness.round,
            }
          end
        end

        time_to_enter_exit = enrolled_clients.group(:project_id).
          sum(:days_to_add_exit_date)
        time_to_enter_exit.each do |id, count|
          denominator = enrolled_clients.where(project_id: id).count
          next if denominator.zero?
          average_timeliness = count.to_f / denominator
          if average_timeliness > timeliness_goal
            issues << {
              project_id: id,
              project_name: projects.detect{|p| p.id == id}.ProjectName,
              label: "Average time to enter exceeds acceptable threshold",
              value: average_timeliness.round,
            }
          end
        end
        issues
      end
      return @timeliness
    end

    def dob_after_entry
      @dob_after_entry ||= begin
        issues = []
        dob_issues = enrolled_clients.group(:project_id).
          where(dob_after_entry_date: true).
          select(:dob_after_entry_date).count
        dob_issues.each do |id, count|
          next if count.zero?
          issues << {
            project_id: id,
            project_name: projects.detect{|p| p.id == id}.ProjectName,
            label: "#{pluralize(count, 'client')}",
            value: count,
          }
        end
        issues
      end
    end

    def final_month_service
      @final_month_service ||= begin
        issues = []
        service_issues = enrolled_clients.group(:project_id).
          where(service_within_last_30_days: true).
          select(:service_within_last_30_days).count
        service_issues.each do |id, count|
          next if count.zero?
          issues << {
            project_id: id,
            project_name: projects.detect{|p| p.id == id}.ProjectName,
            label: "#{pluralize(count, 'client')}",
            value: count,
          }
        end
        issues
      end
    end

    def service_after_exit_date
      @service_after_exit_date ||= begin
        issues = []
        service_issues = exiting_clients.group(:project_id).
          where(service_after_exit: true).
          select(:service_after_exit).count
        service_issues.each do |id, count|
          next if count.zero?
          issues << {
            project_id: id,
            project_name: projects.detect{|p| p.id == id}.ProjectName,
            label: "#{pluralize(count, 'client')}",
            value: count,
          }
        end
        issues
      end
    end

    def household_type_mismatch
      @household_type_mismatch ||= begin
        issues = []
        household_type_issues = enrolled_clients.where(incorrect_household_type: true).group(:project_id).distinct.
          select(:household_type).count
        household_type_issues.each do |id, count|
          next if count.zero?
          project = projects.detect{|p| p.id == id}
          next if project.serves_families? && project.serves_individuals?
          if project.serves_families?
            issues << {
              project_id: id,
              project_name: project.ProjectName,
              label: "individuals at family project",
              value: count,
            }
          else
            issues << {
              project_id: id,
              project_name: project.ProjectName,
              label: "families at individual project",
              value: count,
            }
          end
        end
        issues
      end
    end

    def enrollments_with_no_service
      @enrollments_with_no_service ||= begin
        issues = []
        service_issues = enrolled_clients.group(:project_id).
          where(days_of_service: 0).
          select(:days_of_service).count
        service_issues.each do |id, count|
          next if count.zero?
          issues << {
            project_id: id,
            project_name: projects.detect{|p| p.id == id}.ProjectName,
            label: "#{pluralize(count, 'client')}",
            value: count,
          }
        end
        issues
      end
    end

    def move_in_date_after_threshold
      @move_in_date_after_threshold ||= begin
        issues = []
        move_in_date_issues = move_in_date_above_threshold.group(:project_id).
          select(:days_ph_before_move_in_date).count
        move_in_date_issues.each do |id, count|
          next if count.zero?
          issues << {
            project_id: id,
            project_name: projects.detect{|p| p.id == id}.ProjectName,
            label: "#{pluralize(count, 'client')}",
            value: count,
          }
        end
        issues
      end
    end

    # formatted for billboardjs
    def bed_census_data
      @bed_census_data ||= begin
        dates = report_range.range.to_a
        data = {}
        report_projects.each do |report_project|
          data[projects.detect{|p| p.id == report_project.project_id}.ProjectName] = report_project.nightly_client_census.values
        end
        if report_type == :project_group
          data['Total'] = report_project_group.nightly_client_census.values
        end
        {
          labels: dates,
          data: data,
        }
      end
    end

    def unit_census_data
      @unit_census_data ||= begin
        dates = report_range.range.to_a
        data = {}
        report_projects.each do |report_project|
          data[projects.detect{|p| p.id == report_project.project_id}.ProjectName] = report_project.nightly_household_census.values
        end
        if report_type == :project_group
          data['Total'] = report_project_group.nightly_household_census.values
        end
        {
          labels: dates,
          data: data,
        }
      end
    end

    def describe_time_to_enter
      @describe_time_to_enter ||= begin
        issues = []
        time_to_enter_by_project_id.each do |id, count|
          denominator = enrolled_clients.where(project_id: id).count
          average_timeliness = count.to_f / denominator
          issues << {
            project_id: id,
            project_name: projects.detect{|p| p.id == id}.ProjectName,
            label: pluralize(average_timeliness.round, 'day'),
          }
        end
        issues
      end
    end

    def time_to_enter_by_project_id
      @time_to_enter_by_project_id ||= enrolled_clients.group(:project_id).
        sum(:days_to_add_entry_date)
    end

    def describe_time_to_exit
      @describe_time_to_exit ||= begin
        issues = []
        report_projects.each do |project|
          count = time_to_exit_by_project_id[project.id] || 0
          denominator = exiting_clients.where(project_id: project.project_id).count
          average_timeliness = (count.to_f / denominator).round rescue 0
          issues << {
            project_id: project.id,
            project_name: project.project_name,
            label: pluralize(average_timeliness, 'day'),
          }
        end
        issues
      end
    end

    def time_to_exit_by_project_id
      @time_to_exit_by_project_id ||= exiting_clients.group(:project_id).
        sum(:days_to_add_exit_date)
    end

    def average_time_to_enter
      @average_time_to_enter ||= begin
        # these need to be padded front and back for chart js to correctly show the goal
        labels = ['', 'Days to Entry', '']
        data = {}
        goal = [timeliness_goal, timeliness_goal, timeliness_goal]
        report_projects.each do |project|
          count = time_to_enter_by_project_id[project.project_id] || 0
          denominator = enrolled_clients.where(project_id: project.project_id).count
          average_timeliness = (count.to_f / denominator).round rescue 0
          data[project.project_name] = [0, average_timeliness, 0]
        end
        data['Goal'] = goal
        {
          labels: labels,
          data: data,
          projects: projects.pluck(:ProjectName, :id).to_h,
        }
      end
    end

    def average_time_to_exit
      @average_time_to_exit ||= begin
        # these need to be padded front and back for chart js to correctly show the goal
        labels = ['', 'Days to Exit', '']
        data = {}
        goal = [timeliness_goal, timeliness_goal, timeliness_goal]
        report_projects.each do |project|
          count = time_to_exit_by_project_id[project.project_id] || 0
          denominator = exiting_clients.where(project_id: project.project_id).count
          average_timeliness = (count.to_f / denominator).round rescue 0
          data[project.project_name] = [0, average_timeliness, 0]
        end
        data['Goal'] = goal
        {
          labels: labels,
          data: data,
          projects: projects.pluck(:ProjectName, :id).to_h,
        }
      end
    end

    def average_time_in_project
      @average_time_in_project ||= begin
        issues = []
        days_by_project_id = enrolled_clients.group(:project_id).
          sum(:days_of_service)
        report_projects.each do |project|
          count = days_by_project_id[project.project_id]
          denominator = enrolled_clients.where(project_id: project.project_id).count
          average = count.to_f / denominator
          issues << {
            project_id: project.project_id,
            project_name: project.project_name,
            label: pluralize(average.round, 'day'),
          }
        end
        issues
      end
    end

    def percent_in_project_over_one_year
      @percent_in_project_over_one_year ||= begin
        issues = []
        more_than_one_year = enrolled_clients.group(:project_id).
          where(days_of_service: (365..Float::INFINITY)).count
        report_projects.each do |project|
          count = more_than_one_year[project.project_id]
          denominator = enrolled_clients.where(project_id: project.project_id).count
          percent_over_one_year = ((count.to_f / denominator) * 100).round rescue 0
          issues << {
            project_id: project.project_id,
            project_name: project.project_name,
            label: pluralize(count, 'client'),
            percent: percent_over_one_year,
          }
        end
        issues
      end
    end

    def enrolled_length_of_stay
      @enrolled_length_of_stay ||= begin
        # these need to be padded front and back for chart js to correctly show the goal
        labels = self.class.length_of_stay_buckets.keys
        data = {}
        totals = []
        self.class.length_of_stay_buckets.values.each_with_index do |range, index|
          report_projects.each do |project|
            data[project.project_name] ||= []
            totals[index] ||= 0
            count = enrolled_clients.where(
              project_id: project.project_id,
              days_of_service: range,
            ).count
            data[project.project_name] << count
            totals[index] += count
          end
        end
        {
          labels: labels,
          data: data.merge({'Totals' => totals}),
          ranges: self.class.length_of_stay_buckets,
          projects: projects.pluck(:ProjectName, :id).to_h,
        }
      end
    end

    def ph_destinations
      @ph_destinations ||= begin
        data = {}
        labels = ["","Exit %",""]
        goal = [ph_destination_increase_goal, ph_destination_increase_goal, ph_destination_increase_goal]

        report_projects.each do |project|
          denominator = exiting_clients.where(project_id: project.project_id).count
          count = exiting_clients.where(
            project_id: project.project_id,
            destination_id: HUD.permanent_destinations,
          ).count
          percentage = ((count / denominator.to_f) * 100).round rescue 0
          data[project.project_name] = [0, percentage, 0]
        end
        data['Goal'] = goal
        {
          labels: labels,
          data: data,
          projects: projects.pluck(:ProjectName, :id).to_h,
        }
      end
    end

    def percent_exiting_to_ph
      @percent_exiting_to_ph ||= begin
        issues = []
        report_projects.each do |project|
          denominator = exiting_clients.where(project_id: project.project_id).count
          count = exiting_clients.where(
            project_id: project.project_id,
            destination_id: HUD.permanent_destinations,
          ).count
          percentage = ((count / denominator.to_f) * 100).round rescue 0
          issues << {
            project_id: project.project_id,
            project_name: project.project_name,
            label: "#{pluralize(count, 'client')}",
            percent: percentage,
          }
        end
        if report_type == :project_group
          denominator = exiting_clients.count
          count = exiting_clients.where(
            destination_id: HUD.permanent_destinations,
          ).count
          percentage = ((count / denominator.to_f) * 100).round rescue 0
          issues << {
            project_id: nil,
            project_name: 'Overall',
            label: "#{pluralize(count, 'client')}",
            percent: percentage,
          }
        end
        issues
      end
    end

    # NOTE: this is for all participating projects, not broken out by project
    # Also NOTE: SPM calculates the change against the two most recent income records, NOT, entry and the most recent
    def retained_income
      @retained_income ||= begin
        labels = ['Increased or Retained','20% Increase']
        # clients with at least two income records
        included_clients = enrolled_clients.where.not(income_at_later_date_overall: nil)
        a_t = Reporting::DataQualityReports::Enrollment.arel_table
        denominator = included_clients.count
        earned_retained = included_clients.where(
          a_t[:income_at_later_date_earned].gteq(a_t[:income_at_entry_earned])
        ).count
        non_employment_cash_retained = included_clients.where(
          a_t[:income_at_later_date_non_employment_cash].gteq(a_t[:income_at_entry_non_employment_cash])
        ).count
        overall_retained = included_clients.where(
          a_t[:income_at_later_date_overall].gteq(a_t[:income_at_entry_overall])
        ).count

        earned_retained_20 = included_clients.where(
          a_t[:income_at_later_date_earned].gt(a_t[:income_at_entry_earned] * Arel::Nodes::SqlLiteral.new('1.20') )
        ).count
        non_employment_cash_retained_20 = included_clients.where(
          a_t[:income_at_later_date_non_employment_cash].gt(a_t[:income_at_entry_non_employment_cash] * Arel::Nodes::SqlLiteral.new('1.20') )
        ).count
        overall_retained_20 = included_clients.where(
          a_t[:income_at_later_date_overall].gt(a_t[:income_at_entry_overall] * Arel::Nodes::SqlLiteral.new('1.20') )
        ).count

        earned_retained_percentage = ((earned_retained / denominator.to_f) * 100).round rescue 0
        non_employment_cash_retained_percentage = ((non_employment_cash_retained / denominator.to_f) * 100).round rescue 0
        overall_retained_percentage = ((overall_retained / denominator.to_f) * 100).round rescue 0

        earned_retained_20_percentage = ((earned_retained_20 / denominator.to_f) * 100).round rescue 0
        non_employment_cash_retained_20_percentage = ((non_employment_cash_retained_20 / denominator.to_f) * 100).round rescue 0
        overall_retained_20_percentage = ((overall_retained_20 / denominator.to_f) * 100).round rescue 0
        data = {
          'Earned Income' => [
            earned_retained_percentage,
            earned_retained_20_percentage,
          ],
          'Non-Employment Cash Income' => [
            non_employment_cash_retained_percentage,
            non_employment_cash_retained_20_percentage,
          ],
          'Overall Income' => [
            overall_retained_percentage,
            overall_retained_20_percentage,
          ],
          'Goal' => [
            income_increase_goal,
            income_increase_goal,
          ]
        }
      end
      {
        labels: labels,
        data: data,
      }
    end

    def completeness_percentage
      []
    end

    def project_group_completeness
      @project_group_completeness ||= begin
        labels = completeness_metrics.map{ |_,m| m[:label] }
        data = completeness_type_labels.map do |_, label|
          [label, Array.new(completeness_metrics.keys.count, 0)]
        end.to_h
        data['Target'] = Array.new(completeness_metrics.keys.count, completeness_goal)
        completeness_metrics.each_with_index do |(key, options), index|
          ([:complete] + options[:measures]).each do |measure|
            count = send(options[:denominator]).where("#{key}_#{measure}" => true).count
            denominator = send(options[:denominator]).count
            if denominator.zero? && measure == :complete
              percentage = 100
            else
              percentage = ((count.to_f / denominator) * 100).round rescue 0
            end
            data[completeness_type_labels[measure]][index] = percentage
          end
        end
        {
          labels: labels,
          data: data,
          columns: completeness_metrics.keys,
        }
      end
    end

    def project_completeness hud_project:
      # don't cache this
      @project_completeness = begin
        labels = completeness_metrics.map{ |_,m| m[:label] }
        data = completeness_type_labels.map do |_, label|
          [label, Array.new(completeness_metrics.keys.count, 0)]
        end.to_h
        data['Target'] = Array.new(completeness_metrics.keys.count, completeness_goal)
        completeness_metrics.each_with_index do |(key, options), index|
          ([:complete] + options[:measures]).each do |measure|
            count = send(options[:denominator]).where(project_id: hud_project.id, "#{key}_#{measure}" => true).count
            denominator = send(options[:denominator]).where(project_id: hud_project.id).count
            if denominator.zero? && measure == :complete
              percentage = 100
            else
              percentage = ((count.to_f / denominator) * 100).round rescue 0
            end
            data[completeness_type_labels[measure]][index] = percentage
          end
        end
        {
          labels: labels,
          data: data,
          columns: completeness_metrics.keys,
        }
      end
    end

  end
end