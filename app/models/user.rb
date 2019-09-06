###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  has_paper_trail
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :confirmable, :pwned_password, password_length: 10..128
  #has_secure_password # not needed with devise

  validates :email, presence: true, uniqueness: true, email_format: { check_mx: true }, length: {maximum: 250}, on: :update
  validates :last_name, presence: true, length: {maximum: 40}
  validates :first_name, presence: true, length: {maximum: 40}
  validates :email_schedule, inclusion: { in: Message::SCHEDULES }, allow_blank: false

  has_many :user_roles, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :user_roles

  has_many :user_clients, class_name: GrdaWarehouse::UserClient.name
  has_many :clients, through: :user_clients, inverse_of: :users, dependent: :destroy
  has_many :entities, class_name: GrdaWarehouse::UserViewableEntity.name

  has_many :messages

  belongs_to :agency

  scope :receives_file_notifications, -> do
    where(receive_file_upload_notifications: true)
  end
  scope :active, -> {where active: true}
  scope :inactive, -> {where active: false}
  scope :not_system, -> { where.not(first_name: 'System') }

  # NOTE: users and rows in this join table are in different databases, so transactions
  # aren't going to play well across this boundary
  after_destroy do |user|
    GrdaWarehouse::UserViewableEntity.where( user_id: user.id ).destroy_all
  end

  # scope :admin, -> { includes(:roles).where(roles: {name: :admin}) }
  # scope :dnd_staff, -> { includes(:roles).where(roles: {name: :dnd_staff}) }

  # load a hash of permission names (e.g. 'can_view_all_reports')
  # to a boolean true if the user has the permission through one
  # of their roles
  def load_effective_permissions
    {}.tap do |h|
      roles.each do |role|
        Role.permissions.each do |permission|
          h[permission] ||= role.send(permission)
        end
      end
    end
  end

  # define helper methods for looking up if this
  # user has an permission through one of its roles
  Role.permissions.each do |permission|
    define_method(permission) do
      @permissions ||= load_effective_permissions
      @permissions[permission]
    end

    # Methods for determining if a user has permission
    # e.g. the_user.can_administer_health?
    define_method("#{permission}?") do
      self.send(permission)
    end

    # Provide a scope for each permission to get any user who qualifies
    # e.g. User.can_administer_health
    scope permission, -> do
      joins(:roles).
      where(roles: {permission => true})
    end
  end

  def active_for_authentication?
    super && active
  end

  def has_administrative_access_to_health?
      can_administer_health? || can_manage_health_agency? || can_manage_claims? || can_manage_all_patients? || has_patient_referral_review_access?
  end

  def has_patient_referral_review_access?
    can_approve_patient_assignments? || can_manage_patients_for_own_agency?
  end

  def has_some_patient_access?
    can_approve_cha? || can_approve_ssm? || can_approve_participation? || can_approve_release? || can_edit_all_patient_items? || can_edit_patient_items_for_own_agency? || can_view_all_patients? || can_view_patients_for_own_agency?
  end

  def can_access_some_version_of_clients?
    can_view_client_window? || can_view_clients? || can_edit_clients?
  end

  def has_some_edit_access_to_youth_intakes?
    can_edit_youth_intake? || can_edit_own_agency_youth_intake?
  end

  def limited_client_view?
    ! can_view_clients?
  end

  def self.stale_account_threshold
    30.days.ago
  end

  def stale_account?
    current_sign_in_at < self.class.stale_account_threshold
  end


  # def role_keys
  #   [:admin, :dnd_staff, :housing_subsidy_admin]
  #     .select { |role| attributes[role.to_s] }
  # end

  # def roles_string
  #   role_keys
  #     .map { |role_key| role_key.to_s.humanize.gsub 'Dnd', 'DND' }
  #     .join(', ')
  # end

  def name
    "#{first_name} #{last_name}"
  end

  def name_with_email
    "#{name} <#{email}>"
  end

  def invitation_status
    if invitation_accepted_at.present? || invitation_sent_at.blank?
      :active
    elsif invitation_due_at > Time.now
      :pending_confirmation
    else
      :invitation_expired
    end
  end

  def self.text_search(text)
    return none unless text.present?

    query = "%#{text}%"
    where(
      arel_table[:last_name].matches(query)
      .or(arel_table[:first_name].matches(query))
      .or(arel_table[:email].matches(query))
    )
  end

  def self.setup_system_user
    user = User.find_by(email: 'noreply@greenriver.com')
    return user if user.present?
    user = User.with_deleted.find_by(email: 'noreply@greenriver.com')
    if user.present?
      user.restore
    end
    user = User.invite!(email: 'noreply@greenriver.com', first_name: 'System', last_name: 'User') do |u|
      u.skip_invitation = true
    end
    return user
  end

  def data_sources
    viewable GrdaWarehouse::DataSource
  end

  def organizations
    viewable GrdaWarehouse::Hud::Organization
  end

  def projects
    viewable GrdaWarehouse::Hud::Project
  end

  def reports
    viewable GrdaWarehouse::WarehouseReports::ReportDefinition
  end

  def cohorts
    viewable GrdaWarehouse::Cohort
  end

  def project_groups
    viewable GrdaWarehouse::ProjectGroup
  end

  def associated_by associations:
    return [] unless associations.present?
    associations.flat_map do |association|
      case association
      when :coc_code
        coc_codes.map do |code|
          [
            code,
            GrdaWarehouse::Hud::Project.project_names_for_coc(code)
          ]
        end
      when :organization
        organizations.preload(:projects).map do |org|
          [
            org.OrganizationName,
            org.projects.map(&:ProjectName)
          ]
        end
      when :data_source
        data_sources.preload(:projects).map do |ds|
          [
            ds.name,
            ds.projects.map(&:ProjectName)
          ]
        end
      else
        []
      end
    end
  end

  def user_care_coordinators
    Health::UserCareCoordinator.where(user_id: id)
  end

  def care_coordinators
    ids = user_care_coordinators.pluck(:care_coordinator_id)
    User.where(id: ids)
  end

  def user_team_coordinators
    Health::UserCareCoordinator.where(care_coordinator_id: id)
  end

  def team_coordinators
    ids = user_team_coordinators.pluck(:user_id)
    User.where(id: ids)
  end

  def set_viewables(viewables)
    return unless persisted?
    GrdaWarehouse::UserViewableEntity.transaction do
      %i( data_sources organizations projects reports cohorts project_groups ).each do |type|
        ids = ( viewables[type] || [] ).map(&:to_i)
        scope = viewable_join self.send(type)
        scope.where.not( entity_id: ids ).destroy_all
        ( ids - scope.pluck(:id) ).each{ |id| scope.where( entity_id: id ).first_or_create }
      end
    end
  end

  def add_viewable(*viewables)
    viewables.each do |viewable|
      viewable_join(viewable.class).where( entity_id: viewable.id ).first_or_create
    end
  end

  def can_see_admin_menu?
    can_edit_users? || can_edit_translations? || can_administer_health? || can_manage_config?
  end

  def self.can_receive_secure_files?
    can_view_assigned_secure_uploads || can_view_all_secure_uploads
  end

  def admin_dashboard_landing_path
    return admin_users_path if can_edit_users?
    return admin_configs_path if can_manage_config?
    return admin_translation_keys_path if can_edit_translations?
    return admin_dashboard_imports_path if can_view_imports?
  end

  def subordinates
    return [] unless can_manage_organization_users?
    # Administrative permission to see all assignments
    if can_view_all_user_client_assignments?
      return User.all
    end
    uve_source = GrdaWarehouse::UserViewableEntity
    uve_t = uve_source.arel_table

    data_source_ids = data_sources.pluck(:id)

    organization_ids = organizations.pluck(:id) + GrdaWarehouse::Hud::Organization.
      where(data_source_id: data_source_ids ).pluck(:id)

    project_ids = projects.pluck(:id) + GrdaWarehouse::Hud::Project.
      where(OrganizationID: organization_ids).
      pluck(:id) + GrdaWarehouse::Hud::Project.
        where(data_source_id: data_source_ids).
        pluck(:id)

    data_source_members = uve_t[:entity_id].in(data_source_ids)
      .and(uve_t[:entity_type].eq('GrdaWarehouse::DataSource'))
    organization_members = uve_t[:entity_id].in(organization_ids)
      .and(uve_t[:entity_type].eq('GrdaWarehouse::Hud::Organization'))
    project_members = uve_t[:entity_id].in(project_ids)
      .and(uve_t[:entity_type].eq('GrdaWarehouse::Hud::Project'))

    sub_ids = uve_source.where(data_source_members.or(organization_members).or(project_members)).distinct.pluck(:user_id)

    manager_ids = User.includes(:roles)
      .references(:roles)
      .where( roles: { can_manage_organization_users: true } )
      .pluck(:id)

    User.where(id: sub_ids - manager_ids)
  end

  # def health_agency
  #   agency_user&.agency
  # end

  # def agency_user
  #   Health::AgencyUser.where(user_id: id).last
  # end

  def health_agencies
    agency_users.map(&:agency)
  end

  def health_agency_names
    health_agencies.map(&:name)
  end

  def agency_users
    Health::AgencyUser.where(user_id: id)
  end

  # send email upon creation or only in a periodic digest
  def continuous_email_delivery?
    email_schedule.nil? || email_schedule == 'immediate'
  end

  # does this user want to see messages in the app itself (versus only in email)
  # TODO make this depend on some attribute(s) configurable by the user and/or admins
  def in_app_messages?
    true
  end

  def self.describe_changes(version, changes)
    changes.slice(*whitelist_for_changes_display).map do |name, values|
      "Changed #{humanize_attribute_name(name)}: from \"#{values.first}\" to \"#{values.last}\"."
    end
  end

  def self.humanize_attribute_name(name)
    name.humanize.titleize
  end

  private

    def self.whitelist_for_changes_display
      [
        'first_name',
        'last_name email',
        'phone',
        'agency',
        'receive_file_upload_notifications',
        'notify_of_vispdat_completed',
        'notify_on_anomaly_identified',
      ].freeze
    end

    def viewable(model)
      if can_edit_anything_super_user?
        model.all
      else
        model.joins(:user_viewable_entities).merge(viewable_join(model))
      end
    end

    def viewable_join(model)
      GrdaWarehouse::UserViewableEntity.where(
        entity_type: model.sti_name,
        user_id: id
      )
    end

end
