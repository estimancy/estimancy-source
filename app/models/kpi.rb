class Kpi < ActiveRecord::Base

  serialize :indicator_result, Array

  validates :organization_id, presence: true
  validates :name, presence: true

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

  def get_config_label
    organization = self.organization
    application_id = self.application_id
    project_area_id = self.project_area_id
    project_category_id = self.project_category_id
    acquisition_category_id = self.acquisition_category_id
    platform_category_id = self.platform_category_id
    provider_id = self.provider_id


    config_for_graph = "#{self.name} ( "

    selected_date = self.selected_date || "start_date"
    selected_date_label = selected_date == "start_date" ?  I18n.t(selected_date) : I18n.t(:created_date)
    config_for_graph = config_for_graph + "  " + "Date" + " = "  + selected_date_label

    unless application_id.blank?
      application = organization.applications.where(id: application_id).first
      config_for_graph = config_for_graph + " -  " + "#{I18n.t(:application)}: #{application.name}"
    end

    unless project_area_id.blank?
      project_area = organization.project_areas.where(id: project_area_id).first
      config_for_graph = config_for_graph + "  -  " +  "#{I18n.t(:project_area)}: #{project_area.name}"
    end

    unless project_category_id.blank?
      project_category = organization.project_categories.where(id: project_category_id).first
      config_for_graph = config_for_graph + "  -  " +  "#{I18n.t(:project_category)}: #{project_category.name}"
    end

    unless acquisition_category_id.blank?
      acquisition_category = organization.acquisition_categories.where(id: acquisition_category_id).first
      config_for_graph = config_for_graph + "  -  " + "#{I18n.t(:acquisition_category)}: #{acquisition_category.name}"
    end

    unless platform_category_id.blank?
      platform_category = organization.platform_categories.where(id: platform_category_id).first
      config_for_graph = config_for_graph + "  -  " + "#{I18n.t(:platform_category)}: #{platform_category.name}"
    end

    unless provider_id.blank?
      provider = organization.providers.where(id: provider_id).first
      config_for_graph = config_for_graph + "  -  " + "#{I18n.t(:provider)}: #{provider.name}"
    end

    config_for_graph+ " ) "
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


  def self.period_dates_collection
    [[I18n.t(:current_date), "current_date"],
     [I18n.t(:date_week), "date_week"],
     [I18n.t(:date_month), "date_month"],
     [I18n.t(:date_trimester), "date_trimester"],
     [I18n.t(:date_semester), "date_semester"],
     [I18n.t(:date_year), "date_year"],
     [I18n.t(:enter_date), "enter_date"]
    ]
  end


  def self.x_axis_config_collection
    [
     [I18n.t(:label_date),
        [ [I18n.t(:date_detail), "date_detail"],
          [I18n.t(:date_week), "date_week"],
          [I18n.t(:date_month), "date_month"],
          [I18n.t(:date_trimester), "date_trimester"],
          [I18n.t(:date_semester), "date_semester"],
          [I18n.t(:date_year), "date_year"]
        ]
     ],

     [ "Autres",
       [
         [I18n.t(:estimation_models), "original_model"], [I18n.t(:estimation_status), "estimation_status"],
         [I18n.t(:application), "application"], [I18n.t(:project_area), "project_area"], [I18n.t(:project_category), "project_category"],
         [I18n.t(:acquisition_category), "acquisition_category"], [I18n.t(:platform_category), "platform_category"],
         [I18n.t(:provider), "provider"]
       ]
     ]
    ]
  end

  def self.y_axis_config_collection
    [[I18n.t(:minimum), "minimum"], [I18n.t(:maximum), "maximum"], [I18n.t(:average), "average"],
     [I18n.t(:median), "median"], [I18n.t(:sum), "sum"], [I18n.t(:counter), "counter"]]
  end
end
