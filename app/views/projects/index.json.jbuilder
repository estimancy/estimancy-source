json.array!(@projects) do |project|
  json.id project.id
  json.project project.title
  json.version_number project.version_number
  json.description project.description
  json.state project.state
  json.start_date project.start_date
  json.created_at project.created_at
  json.is_model project.is_model
  json.url edit_project_url(project)

  json.owner do
    if project.creator
      json.name "#{project.creator.first_name} #{project.creator.last_name}"
      json.email project.creator.email
    else
      json.name nil
      json.email nil
    end
  end

  json.organizations do
    json.id project.organization.id
    json.title project.organization.name
  end

  json.components project.pbs_project_elements do |e|
    json.id e.id
    json.name e.name
    json.requirement e.description
    json.root e.is_root
    json.ancestry e.ancestry
    if e.organization_technology.nil?
      json.technology nil
    else
      json.technology e.organization_technology.name
    end
  end

  json.estimation_plans project.module_projects do |mp|
    json.id mp.id
    json.title mp.pemodule.title
    json.x mp.position_x
    json.y mp.position_y
    json.estimation_datas mp.estimation_values do |ev|
      json.id ev.id
      json.io ev.in_out
      json.result_datas do
        json.low ev.string_data_low.keys do |k|
          if k.is_a?(Integer)
            json.pbs_project_element_id k
            json.value ev.string_data_low[k]
          elsif k == :pe_attribute_name
            json.attribute do
              json.name ev.pe_attribute.name
              json.description ev.pe_attribute.description
            end
          elsif k == :default_low
            json.default_value ev.string_data_low[k]
          end
        end

        json.most_likely ev.string_data_most_likely.keys do |k|
          if k.is_a?(Integer)
            json.pbs_project_element_id k
            json.value ev.string_data_most_likely[k]
          elsif k == :pe_attribute_name
            json.attribute do
              json.name ev.pe_attribute.name
              json.description ev.pe_attribute.description
            end
          elsif k == :default_most_likely
            json.default_value ev.string_data_most_likely[k]
          end
        end

        json.high ev.string_data_high.keys do |k|
          if k.is_a?(Integer)
            json.pbs_project_element_id k
            json.value ev.string_data_high[k]
          elsif k == :pe_attribute_name
            json.attribute do
              json.name ev.pe_attribute.name
              json.description ev.pe_attribute.description
            end
          elsif k == :default_high
            json.default_value ev.string_data_high[k]
          end
        end
      end
    end
  end
end

