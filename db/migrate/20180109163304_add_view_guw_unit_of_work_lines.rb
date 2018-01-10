class AddViewGuwUnitOfWorkLines < ActiveRecord::Migration
  def up
    execute <<-SQL

      CREATE OR REPLACE VIEW guw_unit_of_work_lines AS

      SELECT o.id AS uow_organization_id, o.name AS organization_name,
                    p.id AS uow_project_id, p.title AS project_name,
                    mp.id AS uow_module_project_id,
                    guw_uow.pbs_project_element_id AS uow_pbs_project_element_id,
                    guw_model.id AS uow_guw_model_id,
                    guw_model.name AS uow_guw_model_name,
                    guw_uow.guw_unit_of_work_group_id AS guw_uow_group_id,
                    guw_uow_group.name AS guw_uow_group_name,
                    guw_uow.selected AS uow_selected,
                    guw_uow.id AS guw_unit_of_work_id, guw_uow.*,
                    ceuw.guw_coefficient_element_id, ceuw.guw_coefficient_id, ceuw.percent, ceuw.comments as ceuw_comments

      FROM guw_guw_unit_of_works guw_uow

      INNER JOIN organizations o ON o.id = guw_uow.organization_id
      INNER JOIN projects p ON p.id = guw_uow.project_id
      INNER JOIN module_projects mp ON mp.id = guw_uow.module_project_id
      INNER JOIN guw_guw_models guw_model ON guw_model.id = guw_uow.guw_model_id
      INNER JOIN guw_guw_unit_of_work_groups guw_uow_group ON guw_uow_group.id = guw_uow.guw_unit_of_work_group_id

      INNER JOIN guw_guw_coefficient_element_unit_of_works ceuw ON ceuw.guw_unit_of_work_id = guw_uow.id AND ceuw.module_project_id = mp.id

      ORDER BY uow_organization_id, uow_project_id, uow_module_project_id, uow_pbs_project_element_id, uow_guw_model_id, guw_uow_group_id, guw_uow.selected, guw_uow.display_order, guw_uow.name
    SQL
  end


  def down
    execute "DROP VIEW guw_unit_of_work_lines"
  end

end
