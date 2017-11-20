class ModuleProjectGuwUnitOfWorkGroup < ActiveRecord::Base
  self.primary_key = 'guw_unit_of_work_group_id'

  has_many :guw_unit_of_works, class_name: "Guw::GuwUnitOfWork", foreign_key: 'guw_unit_of_work_group_id'

  # la Vue
  has_many :module_project_guw_unit_of_works, class_name: 'ModuleProjectGuwUnitOfWork', foreign_key: 'guw_unit_of_work_group_id'

  belongs_to :module_project
  belongs_to :pbs_project_element
  belongs_to :organization_technology


  def to_s
    name
  end

end