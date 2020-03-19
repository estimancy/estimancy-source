module Abilities

  def self.ability_for(user, organization, historized)
    if historized == "1"
      AbilityProject.new(user, organization, organization.projects)
    else
      AbilityView.new(user, organization, organization.organization_estimations)
    end
  end
end