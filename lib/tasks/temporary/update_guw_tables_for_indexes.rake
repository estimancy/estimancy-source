# Pour lancer la tache : rake guw:update_guw_tables_for_indexes
# rake guw:update_guw_tables_for_indexes RAILS_ENV=production

namespace :guw do
  desc "Mise à jour des valeurs des nouvelles colonnes ajoutées aux tables de GUW"

  task update_guw_tables_for_indexes: :environment do

    # Re-executer la migration de guw
    # rake db:migrate:down VERSION=20171027100650 RAILS_ENV=production
    # rake db:migrate:up VERSION=20171027100650 RAILS_ENV=production
    # rake db:migrate RAILS_ENV=production

    puts "Update_guw_tables_for_indexes en cours. Début : #{Time.now}"

    puts "\nEstimationValue : #{ EstimationValue.all.size } elements"
    # 2
    ActiveRecord::Base.transaction do
      EstimationValue.all.each_with_index do |ev, index|
        unless ev.module_project.nil?
          ev.organization_id = ev.module_project.organization_id
          ev.save

          progress_bar(index)
        end
      end
    end

    puts "\nGuwCoefficientElementUnitOfWork : #{Guw::GuwCoefficientElementUnitOfWork.all.size} elements"
    # 3 (attention c'est long)
    ActiveRecord::Base.transaction do
      Guw::GuwCoefficientElementUnitOfWork.all.each_with_index do |ceuow, index|
        guw_unit_of_work = ceuow.guw_unit_of_work
        unless guw_unit_of_work.nil?
          if guw_unit_of_work.organization_id.nil?
            ceuow.organization_id = guw_unit_of_work.organization_id
            ceuow.guw_model_id = guw_unit_of_work.guw_model_id
            ceuow.project_id = guw_unit_of_work.project_id
            ceuow.module_project_id = guw_unit_of_work.module_project_id
            ceuow.save(validate: false)

            progress_bar(index)

          end
        end
      end
    end

    puts "\nGuwUnitOfWorkAttribute : #{Guw::GuwUnitOfWorkAttribute.all.size} elements"
    # 4 (attention, c'est long)
    ActiveRecord::Base.transaction do
      Guw::GuwUnitOfWorkAttribute.all.each_with_index do |uow_attr, index|
        guw_unit_of_work = uow_attr.guw_unit_of_work
        unless guw_unit_of_work.nil?
          uow_attr.organization_id = guw_unit_of_work.organization_id
          uow_attr.guw_model_id = guw_unit_of_work.guw_model_id
          uow_attr.project_id = guw_unit_of_work.project_id
          uow_attr.module_project_id = guw_unit_of_work.module_project_id
          uow_attr.save(validate: false)

          progress_bar(index)

        end
      end
    end

    puts "\nModuleProject : #{ModuleProject.all.size} elements"
    # 1
    ModuleProject.all.each_with_index do |mp, index|
      unless mp.project.nil?
        project = mp.project
        mp.organization_id = project.organization_id
        mp.save

        progress_bar(index)
      end
    end

    puts "\nGuwUnitOfWorkGroup : #{Guw::GuwUnitOfWorkGroup.all.size} elements"
    #5
    Guw::GuwUnitOfWorkGroup.all.each_with_index do |uow_gr, index|
      # ActiveRecord::Base.transaction do
        module_project = uow_gr.module_project
        unless module_project.nil?
          uow_gr.organization_id = module_project.organization_id
          uow_gr.guw_model_id = module_project.guw_model_id
          uow_gr.project_id = module_project.project_id
          uow_gr.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwCoefficient : #{Guw::GuwCoefficient.all.size} elements"
    #6
    Guw::GuwCoefficient.all.each_with_index do |coef, index|
      ActiveRecord::Base.transaction do
        guw_model = coef.guw_model
        unless guw_model.nil?
          coef.organization_id = guw_model.organization_id
          coef.save(validate: false)

          progress_bar(index)

        end
      end
    end

    puts "\nGuwCoefficientElement : #{Guw::GuwCoefficientElement.all.size} elements"
    #7
    Guw::GuwCoefficientElement.all.each_with_index do |coef_elt, index|
      # ActiveRecord::Base.transaction do
      guw_coefficient = coef_elt.guw_coefficient
      unless guw_coefficient.nil?

        guw_model = coef_elt.guw_coefficient.guw_model

        unless guw_model.nil?
          coef_elt.organization_id = guw_model.organization_id
          coef_elt.guw_model_id = guw_model.id
          coef_elt.save(validate: false)

          progress_bar(index)

        end
      end
      # end
    end

    puts "\nGuwType : #{Guw::GuwType.all.size} elements"
    #8
    Guw::GuwType.all.each_with_index do |type, index|
      # ActiveRecord::Base.transaction do
        guw_model = type.guw_model
        unless guw_model.nil?
          type.organization_id = guw_model.organization_id
          type.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwOutput : #{Guw::GuwOutput.all.size} elements"
    #9
    Guw::GuwOutput.all.each_with_index do |output, index|
      # ActiveRecord::Base.transaction do
        guw_model = output.guw_model
        unless guw_model.nil?
          output.organization_id = guw_model.organization_id
          output.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwOutputType : #{Guw::GuwOutputType.all.size} elements"
    #10
    Guw::GuwOutputType.all.each_with_index do |output_type, index|
      # ActiveRecord::Base.transaction do
        guw_model = output_type.guw_model
        unless guw_model.nil?
          output_type.organization_id = guw_model.organization_id
          output_type.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwWorkUnit : #{Guw::GuwWorkUnit.all.size} elements"
    #11
    Guw::GuwWorkUnit.all.each_with_index do |wu, index|
      # ActiveRecord::Base.transaction do
        guw_model = wu.guw_model
        unless guw_model.nil?
          wu.organization_id = guw_model.organization_id
          wu.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwComplexity : #{Guw::GuwComplexity.all.size} elements"
    #12
    Guw::GuwComplexity.all.each_with_index do |cplx, index|
      # ActiveRecord::Base.transaction do
      guw_type = cplx.guw_type
      unless guw_type.nil?
        cplx.organization_id = guw_type.organization_id
        cplx.guw_model_id = guw_type.guw_model_id
        cplx.save(validate: false)

        progress_bar(index)

      end
      # end
    end

    puts "\nGuwOutputAssociation : #{Guw::GuwOutputAssociation.all.size} elements"
    #13 guw_guw_output_associations
    Guw::GuwOutputAssociation.all.each_with_index do |output_ass, index|
      # ActiveRecord::Base.transaction do
        complexity = output_ass.guw_complexity
        unless complexity.nil?
          output_ass.organization_id = complexity.organization_id
          output_ass.guw_model_id = complexity.guw_model_id
          output_ass.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwComplexityTechnology : #{Guw::GuwComplexityTechnology.all.size} elements"
    #14
    Guw::GuwComplexityTechnology.all.each_with_index do |cplx_tech, index|
      # ActiveRecord::Base.transaction do
        guw_complexity = cplx_tech.guw_complexity
        unless guw_complexity.nil?
          cplx_tech.organization_id = guw_complexity.organization_id
          cplx_tech.guw_model_id = guw_complexity.guw_model_id
          cplx_tech.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwComplexityWorkUnit : #{Guw::GuwComplexityWorkUnit.all.size} elements"
    #15 guw_type_id et guw_output_id ne sont pas tout le temps remplis
    Guw::GuwComplexityWorkUnit.all.each_with_index do |cplx_wu, index|
      # ActiveRecord::Base.transaction do
        guw_complexity = cplx_wu.guw_complexity
        unless guw_complexity.nil?
          cplx_wu.organization_id = guw_complexity.organization_id
          cplx_wu.guw_model_id = guw_complexity.guw_model_id
          cplx_wu.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwOutputComplexity : #{Guw::GuwOutputComplexity.all.size} elements"
    #16
    Guw::GuwOutputComplexity.all.each_with_index do |output_cplx, index|
      # ActiveRecord::Base.transaction do
        guw_complexity = output_cplx.guw_complexity
        unless guw_complexity.nil?
          output_cplx.organization_id = guw_complexity.organization_id
          output_cplx.guw_model_id = guw_complexity.guw_model_id
          output_cplx.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwOutputComplexityInitialization : #{Guw::GuwOutputComplexityInitialization.all.size} elements"
    #17
    Guw::GuwOutputComplexityInitialization.all.each_with_index do |oci, index|
      # ActiveRecord::Base.transaction do
        guw_complexity = oci.guw_complexity
        unless guw_complexity.nil?
          oci.organization_id = guw_complexity.organization_id
          oci.guw_model_id = guw_complexity.guw_model_id
          oci.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwComplexityCoefficientElement : #{Guw::GuwComplexityCoefficientElement.all.size} elements"
    #18
    Guw::GuwComplexityCoefficientElement.all.each_with_index do |cplx_ce, index|
      ActiveRecord::Base.transaction do
        guw_complexity = cplx_ce.guw_complexity
        unless guw_complexity.nil?
          cplx_ce.organization_id = guw_complexity.organization_id
          cplx_ce.guw_model_id = guw_complexity.guw_model_id
          cplx_ce.save(validate: false)

          progress_bar(index)

        end
      end
    end

    puts "\nGuwAttribute : #{Guw::GuwAttribute.all.size} elements"
    #19
    Guw::GuwAttribute.all.each_with_index do |attr, index|
      # ActiveRecord::Base.transaction do
        guw_model = attr.guw_model
        unless guw_model.nil?
          attr.organization_id = guw_model.organization_id
          attr.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwAttributeType : #{Guw::GuwAttributeType.all.size} elements"
    #20
    Guw::GuwAttributeType.all.each_with_index do |attr_type, index|
      # ActiveRecord::Base.transaction do
        guw_type = attr_type.guw_type
        unless guw_type.nil?
          attr_type.organization_id = guw_type.organization_id
          attr_type.guw_model_id = guw_type.guw_model_id
          attr_type.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwAttributeComplexity : #{Guw::GuwAttributeComplexity.all.size} elements"
    #21
    Guw::GuwAttributeComplexity.all.each_with_index do |attr_cplx, index|
      # ActiveRecord::Base.transaction do
        guw_type = attr_cplx.guw_type
        unless guw_type.nil?
          attr_cplx.organization_id = guw_type.organization_id
          attr_cplx.guw_model_id = guw_type.guw_model_id
          attr_cplx.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    puts "\nGuwTypeComplexity : #{Guw::GuwTypeComplexity.all.size} elements"
    #22
    Guw::GuwTypeComplexity.all.each_with_index do |type_cplx, index|
      # ActiveRecord::Base.transaction do
        guw_type = type_cplx.guw_type
        unless guw_type.nil?
          type_cplx.organization_id = guw_type.organization_id
          type_cplx.guw_model_id = guw_type.guw_model_id
          type_cplx.save(validate: false)

          progress_bar(index)

        end
      # end
    end

    # puts "Terminé : #{Time.now}"

  end

  def progress_bar(index)
    printf("Save: %d ", index)
    # sleep(0.1)
  end

end

