
class CreateOrganizationEstimationsView < ActiveRecord::Migration

  def up

    execute <<-SQL

      CREATE OR REPLACE VIEW organization_estimations AS
       SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*,
       GROUP_CONCAT(f.name, ': ', pf.value SEPARATOR ' ; ') AS project_fields_result

      FROM

      projects p
      INNER JOIN project_fields pf ON p.id = pf.project_id
      INNER JOIN organizations o ON o.id = p.organization_id
      INNER JOIN fields f ON f.id = pf.field_id

      WHERE p.is_model IS NOT TRUE

      GROUP BY pf.project_id

      ORDER BY current_organization_id, project_created_date DESC, p.is_historicized
    SQL

  end


  def down
    execute "DROP VIEW IF EXISTS organization_estimations"
  end

end



# def up_v2

# SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*,
# GROUP_CONCAT(f.name, ': ',pf.value SEPARATOR ';') AS ProjectField
#
# FROM
# projects p
# INNER JOIN project_fields pf ON p.id = pf.project_id
# INNER JOIN organizations o ON o.id = p.organization_id
# INNER JOIN fields f ON f.id = pf.field_id
#
# WHERE p.is_model IS NOT TRUE
# GROUP BY pf.project_id
# ORDER BY current_organization_id, project_created_date DESC, p.is_historicized

#   execute <<-SQL
#
#       CREATE OR REPLACE VIEW organization_estimations AS
#       SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*, f.name AS project_field,
#       FROM projects p
#       INNER JOIN organizations o ON o.id = p.organization_id
#       INNER JOIN fields f ON f.id = p.organization_id
#
#       WHERE p.is_model IS NOT TRUE
#       ORDER BY current_organization_id, project_created_date DESC, p.is_historicized
#   SQL
# end


# CREATE OR REPLACE VIEW organization_estimations AS
# SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*
# FROM projects p
# INNER JOIN organizations o ON o.id = p.organization_id
# WHERE p.is_model IS NOT TRUE
# ORDER BY current_organization_id, project_created_date DESC, p.is_historicized



# rake db:migrate:down VERSION=20170703085928
# rake db:migrate:up VERSION=20170703085928
#AND p.is_historicized IS NOT TRUE

# def up
#
#   execute <<-SQL
#
#       CREATE OR REPLACE VIEW organization_estimations AS
#       SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*
#       FROM projects p
#       INNER JOIN organizations o ON o.id = p.organization_id
#       WHERE p.is_model IS NOT TRUE AND p.is_historicized IS NOT TRUE
#       ORDER BY current_organization_id, project_created_date DESC
#   SQL
#
# end
#
#
# def down
#   execute "DROP VIEW IF EXISTS organization_estimations"
# end