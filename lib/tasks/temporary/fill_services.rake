## rake users:clean_users RAILS_ENV=production

namespace :estimancy do
  desc "Suppression des comptes utilisateurs"

  task services_with_price: :environment do
    project = Project.find(3385)
    organization = project.organization

    mpres = ModuleProjectRatioElement.where(organization_id: project.organization_id,
                                            project_id: project.id,
                                            module_project_id: project.module_projects.last.id).all
    mpres.each do |mpre|
      tjm = mpre.tjm
      mpre_wbs_activity_element_name = mpre.wbs_activity_element.name


      op = OrganizationProfile.where(name: mpre_wbs_activity_element_name)
      op.cost_per_hour = tjm.to_f.round(2)
      op.save

      guw_type = Guw::GuwType.where(organization_id: organization.id, name: mpre_wbs_activity_element_name)

    end

    project

  end
end


