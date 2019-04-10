module GrdaWarehouse::Hud
  class Geography < Base
    include HudSharedScopes
    self.table_name = 'Geography'
    self.hud_key = :GeographyID
    acts_as_paranoid column: :DateDeleted

    def self.hud_csv_headers(version: nil)
      case version
      when '5.1'
        [
          :SiteID,
          :ProjectID,
          :CoCCode,
          :PrincipalSite,
          :Geocode,
          :Address,
          :City,
          :State,
          :ZIP,
          :DateCreated,
          :DateUpdated,
          :UserID,
          :DateDeleted,
          :ExportID
        ].freeze
      else
        [
          :GeographyID,
          :ProjectID,
          :CoCCode,
          :InformationDate,
          :Geocode,
          :GeographyType,
          :Address1,
          :Address2,
          :City,
          :State,
          :ZIP,
          :DateCreated,
          :DateUpdated,
          :UserID,
          :DateDeleted,
          :ExportID,
        ].freeze
      end
    end

    belongs_to :project_coc, class_name: 'GrdaWarehouse::Hud::ProjectCoc', primary_key: [:ProjectID, :CoCCode, :data_source_id], foreign_key: [:ProjectID, :CoCCode, :data_source_id], inverse_of: :geographies
    belongs_to :export, **hud_belongs(Export), inverse_of: :geographies
    has_one :project, **hud_belongs(Project), inverse_of: :geographies, autosave: false

    scope :viewable_by, -> (user) do
      if user.can_edit_anything_super_user?
        current_scope
      elsif user.coc_codes.none?
        none
      else
        joins(:project_coc).merge( GrdaWarehouse::Hud::ProjectCoc.viewable_by user )
      end
    end

    def name
      "#{self.Address} #{self.City}"
    end

    # when we export, we always need to replace GeographyID with the value of id
    # and ProjectID with the id of the related project
    def self.to_csv(scope:)
      attributes = self.hud_csv_headers.dup
      headers = attributes.clone
      attributes[attributes.index(:GeographyID)] = :id
      attributes[attributes.index(:ProjectID)] = 'project.id'

      CSV.generate(headers: true) do |csv|
        csv << headers

        scope.each do |i|
          csv << attributes.map do |attr|
            attr = attr.to_s
            # we need to grab the appropriate id from the related project
            if attr.include?('.')
              obj, meth = attr.split('.')
              i.send(obj).send(meth)
            else
              i.send(attr)
            end
          end
        end
      end
    end
  end
end