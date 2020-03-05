#Suite au passage au nouveau Design, il faudra mettre à jour les positions des module_projects
#au niveau du menu de gauche  "MODULE DE CALCUL"

# rake module_project:update_new_design_module_projects_display_order RAILS_ENV=production

namespace :module_project do
  desc "Suite au passage au nouveau Design, il faudra mettre à jour les positions des module_projects au niveau du menu de gauche 'MODULE DE CALCUL'"

  task update_new_design_module_projects_display_order: :environment do

    @initialization_module = Pemodule.where(alias: 'initialization').first

    Project.all.each do |project|
      display_order = 0

      #Get the initialization module_project
      # @initialization_module_project = project.module_projects.where(pemodule_id: @initialization_module.id).first unless @initialization_module.nil?
      # @initialization_module_project.update_attributes(display_order: 0)
      #project.module_projects.where.not(id: @initialization_module_project.id).order(top_position: :asc, left_position: :asc).each do |module_project|

      project.module_projects.all.sort_by{ |i| i.top_position.to_f }.each do |module_project|
        display_order += 10
        module_project.display_order =  display_order
        module_project.save
      end
    end
  end
end
