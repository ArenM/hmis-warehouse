###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

module GrdaWarehouse::Import::HMISFiveOne
  class Disability < GrdaWarehouse::Hud::Disability
    include ::Import::HMISFiveOne::Shared
    include TsqlImport

    setup_hud_column_access( GrdaWarehouse::Hud::Disability.hud_csv_headers(version: '5.1') )

    self.hud_key = :DisabilitiesID

    def self.date_provided_column
      :InformationDate
    end

    def self.file_name
      'Disabilities.csv'
    end

    # We've seen a bunch of integers come through as floats
    def clean_to_add to_add
      to_add.map do |row|
        row['TCellCount'] = row['TCellCount'].to_i
        row
      end
      # Remove any duplicates that would violate the unique key constraints
      to_add.index_by{|row| row.values_at(*self.unique_constraint.map(&:to_s))}.values
    end

  end
end