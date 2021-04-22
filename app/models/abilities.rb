module Abilities

  def self.ability_for(user, organization, historized, min, max, opp)
    if historized == "1"
      AbilityProject.new(user, organization, organization.projects)
    else
      # begin
        organization_organization_estimations = organization.organization_estimations[min..max]
      # rescue
      #   organization_organization_estimations = organization.organization_estimations
      # end

      AbilityView.new(user, organization, organization_organization_estimations)
    end
  end
end