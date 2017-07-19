class GrdaWarehouse::ImportLog < GrdaWarehouseBase
  include ActionView::Helpers::DateHelper
  serialize :files
  serialize :import_errors
  serialize :summary
  belongs_to :data_source
  has_one :upload, -> { where(percent_complete: 100.0)}, primary_key: [:data_source_id, :completed_at], foreign_key: [:data_source_id, :completed_at]

  scope :viewable_by, -> (user) do
    where(data_source_id: GrdaWarehouse::DataSource.viewable_by(user).select(:id))
  end

  def import_time
    if completed_at.present?
      seconds = ((completed_at - created_at)/1.minute).round * 60
      distance_of_time_in_words(seconds)
    else
      'incomplete'
    end
  end
end