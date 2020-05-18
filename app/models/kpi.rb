class Kpi < ActiveRecord::Base

  validates :organization_id, presence: true

  has_many :kpi_statuses, :dependent=> :destroy
  has_many :estimation_statuses, through: :kpi_statuses, :dependent=> :destroy

  belongs_to :organization
  belongs_to :estimation_model, class_name: "Project", foreign_key: :estimation_model_id

  belongs_to :field
  belongs_to :application
  belongs_to :project_area
  belongs_to :project_category
  belongs_to :acquisition_category
  belongs_to :platform_category
  belongs_to :provider

  amoeba do
    enable
    customize(lambda { |original_kpi, new_kpi|
                new_kpi.copy_id = original_kpi.id
              })
  end

  def get_estimation_model_fields(organization)
    estimation_model_fields = []

    begin
      estimation_model = self.estimation_model
      estimation_model_project_fields = estimation_model.project_fields
      estimation_model_project_fields.each do |pf|
        estimation_model_fields << pf.field
      end
    rescue
      estimation_model_fields = organization.fields.all
    end

    estimation_model_fields
  end
end
