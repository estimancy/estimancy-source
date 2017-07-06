
class CreateOrganizationEstimationsView < ActiveRecord::Migration

  def up

    rename_column :projects, :is_locked, :is_historicized

    execute <<-SQL
      CREATE VIEW organization_estimations AS
      SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*
      FROM projects p
      INNER JOIN organizations o ON o.id = p.organization_id
      WHERE p.is_historicized != true
      ORDER BY current_organization_id, project_created_date DESC

    SQL

  end



  def down
    execute "DROP VIEW organization_estimations"

    rename_column :projects, :is_historicized, :is_locked
  end

end

