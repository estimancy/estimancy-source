module Abilities

  def self.ability_for(user, organization, historized, min, max, opp)
    if historized == "1"
      AbilityProject.new(user, organization, organization.projects)
    else
      # organization_organization_estimations = organization.organization_estimations[min..max]
      AbilityView.new(user, organization, organization.organization_estimations.includes(:project))
    end
  end
end