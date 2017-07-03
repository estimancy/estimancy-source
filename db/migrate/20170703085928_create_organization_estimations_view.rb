
class CreateOrganizationEstimationsView < ActiveRecord::Migration

  def up

    execute <<-SQL
      CREATE VIEW organization_estimations AS
      SELECT o.id AS current_organization_id, o.name AS organization_name, p.start_date AS project_start_date, p.id AS project_id, p.*
      FROM projects p
      INNER JOIN organizations o ON o.id = p.organization_id
      WHERE p.is_historicized != true
      ORDER BY current_organization_id, start_date DESC

    SQL

  end



  def down
    execute "DROP VIEW organization_estimations"
  end

end

