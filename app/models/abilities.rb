module Abilities

  #def self.ability_for(user, organization, historized, min=0, max=10, object_per_page=10)
  def self.ability_for(user, organization, historized, sort_column, sort_order, search_hash, min=0, max=10, object_per_page=10)

    ### v4.3

    if historized == "1"
      all_projects = Project.unscoped.includes(:project_securities).where(:is_model => [nil, false], organization_id: organization.id)
      organization_projects = get_sorted_estimations(organization.id, all_projects, sort_column, sort_order, search_hash)
      AbilityProject.new(user, organization, organization_projects, min, max, object_per_page)
    else
      all_projects = OrganizationEstimation.unscoped.includes([:project]).where(organization_id: organization.id)
      organization_projects = get_sorted_estimations(organization.id, all_projects, sort_column, sort_order, search_hash)
      AbilityProject.new(user, organization, organization_projects, min, max, object_per_page)
    end

    # if historized == "1"
    #   #all_projects = Project.unscoped.includes(:project_securities).where(:is_model => [nil, false], organization_id: organization.id)
    #   all_projects = Project.unscoped.where(:is_model => [nil, false], organization_id: organization.id)
    #   organization_projects = get_sorted_estimations(organization.id, all_projects, @sort_column, @sort_order, @search_hash)
    #   AbilityProject.new(user, organization, organization_projects, @min, @max, @object_per_page)
    # else
    #   all_projects = OrganizationEstimation.unscoped.where(organization_id: organization.id)
    #   organization_projects = get_sorted_estimations(organization.id, all_projects, @sort_column, @sort_order, @search_hash)
    #   AbilityProject.new(user, organization, organization_projects.includes(:project), @min, @max, @object_per_page) ##AbilityView.new(user, organization, organization_projects)
    # end
    ### end for v4.3


    if historized == "1"
      AbilityProject.new(user, organization, organization.projects, min, max, object_per_page)
    else
      #AbilityView.new(user, organization, organization.organization_estimations.includes(:project), min, max, object_per_page)
      AbilityProject.new(user, organization, organization.organization_estimations.includes(:project), min, max, object_per_page)
    end


    # if historized == "1"
    #   AbilityProject.new(user, organization, organization.projects)
    # else
    #   AbilityView.new(user, organization, organization.organization_estimations.includes(:project))
    # end
  end
end