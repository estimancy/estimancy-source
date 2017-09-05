
class CreateOrganizationEstimationsView < ActiveRecord::Migration

  def up

    execute <<-SQL
      CREATE VIEW organization_estimations AS
      SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*
      FROM projects p
      INNER JOIN organizations o ON o.id = p.organization_id
      WHERE p.is_model IS NOT TRUE AND p.is_historicized IS NOT TRUE
      ORDER BY current_organization_id, project_created_date DESC
    SQL

  end


  def down
    execute "DROP VIEW organization_estimations"
  end

end

