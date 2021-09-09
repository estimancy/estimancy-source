module Abilities

  def self.ability_for(user, organization, historized, min, max, opp)

    #AbilityProject.new(user, organization, organization.projects)

    if historized == "1"
      AbilityProject.new(user, organization, organization.projects)
    else
      #AbilityView.new(user, organization, organization.organization_estimations.includes(:project))
      AbilityProject.new(user, organization, organization.organization_estimations.includes(:project))
    end
  end
end