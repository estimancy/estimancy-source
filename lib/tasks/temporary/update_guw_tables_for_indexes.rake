# Pour lancer la tache : rake guw:update_guw_tables_for_indexes
# rake guw:update_guw_tables_for_indexes RAILS_ENV=production

namespace :guw do
  desc "Mise à jour des valeurs des nouvelles colonnes ajoutées aux tables de GUW"

  task update_guw_tables_for_indexes: :environment do

    # Re-executer la migration de guw
    # rake db:migrate:down VERSION=20171027100650
    # rake db:migrate:up VERSION=20171027100650

    ModuleProject.all.each do |mp|
      unless mp.project.nil?
        project = mp.project
        mp.organization_id = project.organization_id
        mp.save
      end
    end

    EstimationValue.all.each do |ev|
      unless ev.module_project.nil?
        ev.organization_id = ev.module_project.organization_id
        ev.save
      end
    end


    Guw::GuwCoefficientElementUnitOfWork.all.each do |ceuow|
      ActiveRecord::Base.transaction do
        guw_unit_of_work = ceuow.guw_unit_of_work
        unless guw_unit_of_work.nil?
          puts "ceuow_id = #{ceuow.id}"
          puts "uow_id = #{guw_unit_of_work.id}"

          ceuow.organization_id = guw_unit_of_work.organization_id
          ceuow.guw_model_id = guw_unit_of_work.guw_model_id
          ceuow.project_id = guw_unit_of_work.project_id
          ceuow.module_project_id = guw_unit_of_work.module_project_id
          ceuow.save
        end
      end
    end


    Guw::GuwUnitOfWorkAttribute.all.each do |uow_attr|
      ActiveRecord::Base.transaction do
        guw_unit_of_work = uow_attr.guw_unit_of_work
        unless guw_unit_of_work.nil?
          uow_attr.organization_id = guw_unit_of_work.organization_id
          uow_attr.guw_model_id = guw_unit_of_work.guw_model_id
          uow_attr.project_id = guw_unit_of_work.project_id
          uow_attr.module_project_id = guw_unit_of_work.module_project_id
          uow_attr.save
        end
      end
    end


    Guw::GuwUnitOfWorkGroup.all.each do |uow_gr|
      ActiveRecord::Base.transaction do
        module_project = uow_gr.module_project
        unless module_project.nil?
          uow_gr.organization_id = module_project.organization_id
          uow_gr.guw_model_id = module_project.guw_model_id
          uow_gr.project_id = module_project.project_id
          uow_gr.save
        end
      end
    end



    Guw::GuwCoefficient.all.each do |coef|
      ActiveRecord::Base.transaction do
        guw_model = coef.guw_model
        unless guw_model.nil?
          coef.organization_id = guw_model.organization_id
          coef.save
        end
      end
    end

    Guw::GuwCoefficientElement.all.each do |coef_elt|
      ActiveRecord::Base.transaction do
        guw_model = coef_elt.guw_model
        unless guw_model.nil?
          coef_elt.organization_id = guw_model.organization_id
          coef_elt.save
        end
      end
    end

    Guw::GuwType.all.each do |type|
      ActiveRecord::Base.transaction do
        guw_model = type.guw_model
        unless guw_model.nil?
          type.organization_id = guw_model.organization_id
          type.save
        end
      end
    end

    Guw::GuwOutput.all.each do |output|
      ActiveRecord::Base.transaction do
        guw_model = output.guw_model
        unless guw_model.nil?
          output.organization_id = guw_model.organization_id
          output.save
        end
      end
    end


    Guw::GuwOutputType.all.each do |output_type|
      ActiveRecord::Base.transaction do
        guw_model = output_type.guw_model
        unless guw_model.nil?
          output_type.organization_id = guw_model.organization_id
          output_type.save
        end
      end
    end

    Guw::GuwWorkUnit.all.each do |wu|
      ActiveRecord::Base.transaction do
        guw_model = wu.guw_model
        unless guw_model.nil?
          wu.organization_id = guw_model.organization_id
          wu.save
        end
      end
    end

    Guw::GuwComplexity.all.each do |cplx|
      ActiveRecord::Base.transaction do
        guw_type = cplx.guw_type
        unless guw_type.nil?
          cplx.organization_id = guw_type.organization_id
          cplx.guw_model_id = guw_type.guw_model_id
          cplx.save
        end
      end
    end

    #guw_guw_output_associations
    Guw::GuwOutputAssociation.all.each do |output_ass|
      ActiveRecord::Base.transaction do
        complexity = output_ass.guw_complexity
        unless complexity.nil?
          output_ass.organization_id = complexity.organization_id
          output_ass.guw_model_id = complexity.guw_model_id
          output_ass.save
        end
      end
    end


    Guw::GuwComplexityTechnology.all.each do |cplx_tech|
      ActiveRecord::Base.transaction do
        guw_complexity = cplx_tech.guw_complexity
        unless guw_complexity.nil?
          cplx_tech.organization_id = guw_complexity.organization_id
          cplx_tech.guw_model_id = guw_complexity.guw_model_id
          cplx_tech.save
        end
      end
    end

    # guw_type_id et guw_output_id ne sont pas tout le temps remplis
    Guw::GuwComplexityWorkUnit.all.each do |cplx_wu|
      ActiveRecord::Base.transaction do
        guw_complexity = cplx_wu.guw_complexity
        unless guw_complexity.nil?
          cplx_wu.organization_id = guw_complexity.organization_id
          cplx_wu.guw_model_id = guw_complexity.guw_model_id
          cplx_wu.save
        end
      end
    end


    Guw::GuwOutputComplexity.all.each do |output_cplx|
      ActiveRecord::Base.transaction do
        guw_complexity = output_cplx.guw_complexity
        unless guw_complexity.nil?
          output_cplx.organization_id = guw_complexity.organization_id
          output_cplx.guw_model_id = guw_complexity.guw_model_id
          output_cplx.save
        end
      end
    end

    Guw::GuwOutputComplexityInitialization.all.each do |oci|
      ActiveRecord::Base.transaction do
        guw_complexity = oci.guw_complexity
        unless guw_complexity.nil?
          oci.organization_id = guw_complexity.organization_id
          oci.guw_model_id = guw_complexity.guw_model_id
          oci.save
        end
      end
    end


    Guw::GuwComplexityCoefficientElement.all.each do |cplx_ce|
      ActiveRecord::Base.transaction do
        guw_complexity = cplx_ce.guw_complexity
        unless guw_complexity.nil?
          cplx_ce.organization_id = guw_complexity.organization_id
          cplx_ce.guw_model_id = guw_complexity.guw_model_id
          cplx_ce.save
        end
      end
    end

    Guw::GuwAttribute.all.each do |attr|
      ActiveRecord::Base.transaction do
        guw_model = attr.guw_model
        unless guw_model.nil?
          attr.organization_id = guw_model.organization_id
          attr.save
        end
      end
    end

    Guw::GuwAttributeType.all.each do |attr_type|
      ActiveRecord::Base.transaction do
        guw_type = attr_type.guw_type
        unless guw_type.nil?
          attr_type.organization_id = guw_type.organization_id
          attr_type.guw_model_id = guw_type.guw_model_id
          attr_type.save
        end
      end
    end

    Guw::GuwAttributeComplexity.all.each do |attr_cplx|
      ActiveRecord::Base.transaction do
        guw_type = attr_cplx.guw_type
        unless guw_type.nil?
          attr_cplx.organization_id = guw_type.organization_id
          attr_cplx.guw_model_id = guw_type.guw_model_id
          attr_cplx.save
        end
      end
    end

    Guw::GuwTypeComplexity.all.each do |type_cplx|
      ActiveRecord::Base.transaction do
        guw_type = type_cplx.guw_type
        unless guw_type.nil?
          type_cplx.organization_id = guw_type.organization_id
          type_cplx.guw_model_id = guw_type.guw_model_id
          type_cplx.save
        end
      end
    end

  end
end

