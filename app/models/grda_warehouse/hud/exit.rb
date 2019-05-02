module GrdaWarehouse::Hud
  class Exit < Base
    include HudSharedScopes
    self.table_name = 'Exit'
    self.hud_key = :ExitID
    acts_as_paranoid column: :DateDeleted

    def self.hud_csv_headers(version: nil)
      case version
      when '5.1'
        [
          :ExitID,
          :ProjectEntryID,
          :PersonalID,
          :ExitDate,
          :Destination,
          :OtherDestination,
          :AssessmentDisposition,
          :OtherDisposition,
          :HousingAssessment,
          :SubsidyInformation,
          :ConnectionWithSOAR,
          :WrittenAftercarePlan,
          :AssistanceMainstreamBenefits,
          :PermanentHousingPlacement,
          :TemporaryShelterPlacement,
          :ExitCounseling,
          :FurtherFollowUpServices,
          :ScheduledFollowUpContacts,
          :ResourcePackage,
          :OtherAftercarePlanOrAction,
          :ProjectCompletionStatus,
          :EarlyExitReason,
          :FamilyReunificationAchieved,
          :DateCreated,
          :DateUpdated,
          :UserID,
          :DateDeleted,
          :ExportID
        ].freeze
      else
        [
          :ExitID,
          :EnrollmentID,
          :PersonalID,
          :ExitDate,
          :Destination,
          :OtherDestination,
          :AssessmentDisposition,
          :OtherDisposition,
          :HousingAssessment,
          :SubsidyInformation,
          :ProjectCompletionStatus,
          :EarlyExitReason,
          :ExchangeForSex,
          :ExchangeForSexPastThreeMonths,
          :CountOfExchangeForSex,
          :AskedOrForcedToExchangeForSex,
          :AskedOrForcedToExchangeForSexPastThreeMonths,
          :WorkPlaceViolenceThreats,
          :WorkplacePromiseDifference,
          :CoercedToContinueWork,
          :LaborExploitPastThreeMonths,
          :CounselingReceived,
          :IndividualCounseling,
          :FamilyCounseling,
          :GroupCounseling,
          :SessionCountAtExit,
          :PostExitCounselingPlan,
          :SessionsInPlan,
          :DestinationSafeClient,
          :DestinationSafeWorker,
          :PosAdultConnections,
          :PosPeerConnections,
          :PosCommunityConnections,
          :AftercareDate,
          :AftercareProvided,
          :EmailSocialMedia,
          :Telephone,
          :InPersonIndividual,
          :InPersonGroup,
          :CMExitReason,
          :DateCreated,
          :DateUpdated,
          :UserID,
          :DateDeleted,
          :ExportID,
        ].freeze
      end
    end

    belongs_to :data_source, inverse_of: :exits
    has_one :client, through: :enrollment, inverse_of: :exits
    belongs_to :direct_client, **hud_belongs(Client), inverse_of: :direct_exits
    belongs_to :enrollment, class_name: GrdaWarehouse::Hud::Enrollment.name, primary_key: [:EnrollmentID, :PersonalID, :data_source_id], foreign_key: [:EnrollmentID, :PersonalID, :data_source_id], inverse_of: :exit
    belongs_to :export, **hud_belongs(Export), inverse_of: :exits
    has_one :project, through: :enrollment
    has_one :destination_client, through: :enrollment

    scope :permanent, -> do
      where(Destination: ::HUD.permanent_destinations)
    end

    #################################
    # Standard Cohort Scopes
    scope :veteran, -> do
      joins(:destination_client).merge(GrdaWarehouse::Hud::Client.veteran)
    end

    scope :non_veteran, -> do
      joins(:destination_client).merge(GrdaWarehouse::Hud::Client.non_veteran)
    end

    scope :family, -> do
      joins(:project).merge(GrdaWarehouse::Hud::Project.family)
    end

    scope :individual, -> do
      joins(:project).merge(GrdaWarehouse::Hud::Project.individual)
    end

    # End Standard Cohort Scopes
    #################################

    def self.related_item_keys
      [
        :PersonalID,
        :EnrollmentID,
      ]
    end
  end
end