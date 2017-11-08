
class CreateModuleProjectGuwUnitOfWorkGroupsView < ActiveRecord::Migration

  def up

    execute <<-SQL

    CREATE VIEW module_project_guw_unit_of_work_groups AS

    SELECT o.id AS uow_organization_id, o.name AS organization_name,
           p.id AS uow_project_id, p.title AS project_name,
           mp.id AS uow_group_module_project_id,
           guw_uow_group.pbs_project_element_id AS uow_group_pbs_project_element_id,
           guw_uow_group.id AS guw_unit_of_work_group_id,

          (SELECT COUNT(*) FROM guw_guw_unit_of_works uow WHERE guw_unit_of_work_group_id = guw_uow_group.id) AS number_of_uow_lines,
          (SELECT COUNT(*) FROM guw_guw_unit_of_works uow WHERE guw_unit_of_work_group_id = guw_uow_group.id AND selected = TRUE) AS number_of_uow_selected_lines,

           guw_uow_group.*

    FROM guw_guw_unit_of_work_groups guw_uow_group

    INNER JOIN organizations o ON o.id = guw_uow_group.organization_id
    INNER JOIN projects p ON p.id = guw_uow_group.project_id
    INNER JOIN module_projects mp ON mp.id = guw_uow_group.module_project_id

    ORDER BY uow_organization_id, uow_project_id, uow_group_module_project_id, uow_group_pbs_project_element_id, guw_uow_group.name
    SQL

  end


  def down
    execute "DROP VIEW module_project_guw_unit_of_work_groups"
  end

end



# CREATE VIEW module_project_guw_unit_of_work_groups AS
#
# SELECT o.id AS uow_organization_id, o.name AS organization_name,
#                                               p.id AS uow_project_id, p.title AS project_name,
#                                                                                  mp.id AS uow_group_module_project_id,
#                                                                                           guw_uow_group.pbs_project_element_id AS uow_group_pbs_project_element_id,
#
#                                                                                                                                   (SELECT SUM(quantity) FROM guw_guw_unit_of_works uow WHERE guw_unit_of_work_group_id = guw_uow_group.id) AS number_of_unit_of_works,
#                                                                                                                                                                                                                                               (SELECT SUM(quantity) FROM guw_guw_unit_of_works uow WHERE guw_unit_of_work_group_id = guw_uow_group.id AND flagged = true) AS number_of_uw_modifies,
#                                                                                                                                                                                                                                                                                                                                                                              (SELECT SUM(quantity) FROM guw_guw_unit_of_works uow WHERE guw_unit_of_work_group_id = guw_uow_group.id AND selected = TRUE) AS number_of_uw_selected,
#
#                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              guw_uow_group.*
#
# FROM guw_guw_unit_of_work_groups guw_uow_group
#
# INNER JOIN organizations o ON o.id = guw_uow_group.organization_id
# INNER JOIN projects p ON p.id = guw_uow_group.project_id
# INNER JOIN module_projects mp ON mp.id = guw_uow_group.module_project_id
#
# ORDER BY uow_organization_id, uow_project_id, uow_group_module_project_id, uow_group_pbs_project_element_id, guw_uow_group.name