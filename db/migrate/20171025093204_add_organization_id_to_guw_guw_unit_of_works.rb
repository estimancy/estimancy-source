class AddOrganizationIdToGuwGuwUnitOfWorks < ActiveRecord::Migration

  def up
    add_column :guw_guw_unit_of_works, :organization_id, :integer, after: :id
    add_column :guw_guw_unit_of_works, :project_id, :integer, after: :organization_id

    add_column :guw_guw_unit_of_work_groups, :organization_id, :integer, after: :id
    add_column :guw_guw_unit_of_work_groups, :project_id, :integer, after: :organization_id

    Guw::GuwUnitOfWork.all.each do |uow|
      uow.organization_id = uow.guw_model.organization_id rescue nil
      uow.project_id = uow.module_project.project_id rescue nil
      uow.save
    end

    Guw::GuwUnitOfWorkGroup.all.each do |uowg|
      uowg.project_id = uowg.module_project.project_id rescue nil
      uowg.organization_id = uowg.module_project.project.organization_id rescue nil
      uowg.save
    end

  end

  def down
    remove_column :guw_guw_unit_of_works, :organization_id
    remove_column :guw_guw_unit_of_works, :project_id

    remove_column :guw_guw_unit_of_work_groups, :organization_id
    remove_column :guw_guw_unit_of_work_groups, :project_id
  end

end
