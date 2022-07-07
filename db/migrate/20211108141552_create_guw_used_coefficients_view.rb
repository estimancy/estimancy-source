class CreateGuwUsedCoefficientsView < ActiveRecord::Migration
  # def change
  #   create_table :guw_used_coefficients_views do |t|
  #   end
  # end


  def up

    execute <<-SQL

      CREATE OR REPLACE VIEW guw_guw_used_coefficient_elements AS

        SELECT guw_coefficient_element.id AS guw_coefficient_element_id, guw_coefficient_element.*

        FROM guw_guw_coefficient_elements guw_coefficient_element
  
        INNER JOIN organizations organization 
                   ON organization.id = guw_coefficient_element.organization_id
  
        INNER JOIN guw_guw_models guw_model 
                   ON guw_model.id = guw_coefficient_element.guw_model_id

        INNER JOIN guw_guw_coefficients guw_coefficient
                   ON guw_coefficient.id = guw_coefficient_element.guw_coefficient_id
        
  
--         INNER JOIN guw_guw_complexity_coefficient_elements guw_complexity_coefficient_element
--                    ON guw_complexity_coefficient_element.guw_coefficient_element_id = guw_complexity_coefficient_element.id
  
--         INNER JOIN guw_guw_types guw_type 
--                    ON guw_type.id = guw_complexity_coefficient_element.guw_type_id
  
        WHERE ( SELECT count(*) FROM guw_guw_complexity_coefficient_elements
                WHERE organization_id = organization.id 
                      AND guw_model_id = guw_model.id 
                      AND guw_coefficient_element_id = guw_coefficient_element.id
--                       AND guw_type_id = guw_type.id
                      AND value IS NOT NULL
              )  > 0

       ORDER BY guw_coefficient_element.organization_id,
                guw_coefficient_element.guw_model_id,
                guw_coefficient_element.guw_coefficient_id,
                guw_coefficient_element.default,
                guw_coefficient_element.display_order;

    SQL

  end


  def up_save

    execute <<-SQL

      CREATE OR REPLACE VIEW guw_coefficients_used AS

--        SELECT o.id AS current_organization_id, o.name AS organization_name, p.created_at AS project_created_date, p.id AS project_id, p.*
       SELECT guw_coefficient.*

      FROM guw_guw_coefficients guw_coefficient

      INNER JOIN guw_guw_models guw_model ON guw_model.id = guw_coefficient.guw_model_id
      INNER JOIN guw_guw_coefficient_elements guw_coefficient_element 
                 ON guw_coefficient_element.guw_coefficient_id = guw_coefficient.id

      WHERE p.is_model IS NOT TRUE AND p.is_historized IS NOT TRUE
      ORDER BY current_organization_id, project_created_date DESC;

    SQL

  end


  def down
    # execute "DROP VIEW IF EXISTS guw_guw_coefficients_used"
    execute "DROP VIEW IF EXISTS guw_guw_used_coefficient_elements"
  end

end
