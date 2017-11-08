class ModuleProjectGuwUnitOfWork < ActiveRecord::Base

  self.primary_key = 'guw_unit_of_work_id'

  belongs_to :guw_type, class_name: "Guw::GuwType"
  belongs_to :guw_model, class_name: "Guw::GuwModel"
  belongs_to :guw_complexity, class_name: "Guw::GuwComplexity"
  belongs_to :guw_unit_of_work_group, class_name: "Guw::GuwUnitOfWorkGroup"
  belongs_to :organization_technology
  belongs_to :guw_work_unit, class_name: "Guw::GuwWorkUnit"
  belongs_to :guw_weighting, class_name: "Guw::GuwWeighting"
  belongs_to :guw_factor, class_name: "Guw::GuwFactor"
  belongs_to :module_project

  has_many :guw_unit_of_work_attributes, class_name: "Guw::GuwUnitOfWorkAttribute", foreign_key: 'guw_unit_of_work_id'
  has_many :guw_coefficient_element_unit_of_works, class_name: "Guw::GuwCoefficientElementUnitOfWork", foreign_key: 'guw_unit_of_work_id'


  serialize :ajusted_size
  serialize :size
  serialize :effort
  serialize :cost

  def to_s
    name
  end

end
