class CreateIndexOrganizationProjectsTitleUniqueness < ActiveRecord::Migration

  #rake db:migrate:down VERSION=20171222153643
  #rake db:migrate:up VERSION=20171222153643
  def up
    #{[76, false, "000151", "1.1"]=>2, [71, false, "000188", "1.1"]=>2, [75, false, "000217", "1.1"]=>2, [75, false, "000306", "1.0-1.0"]=>3, [76, false, "000395", "1.1"]=>3}

    duplicated_project_versions = Project.select(:organization_id, :is_model, :title, :version_number).group(:organization_id, :is_model, :title, :version_number).having("count(*) > 1").size

    duplicated_project_versions.each do |couple_array, nb|
      projects = Project.where(organization_id: couple_array[0], is_model: couple_array[1], title: couple_array[2], version_number: couple_array[3])
      nb_projects = 0
      version_last_number = couple_array[3].last
      new_version = couple_array[3]

      project_with_priority_order = { }
      projects.each do |project|
        case project.estimation_status.name
        when 'Accepté'
          project_with_priority_order[project.id] = 0
        when 'A valider'
          project_with_priority_order[project.id] = 1
        when 'A revoir'
          project_with_priority_order[project.id] = 2
        else
          project_with_priority_order[project.id] = 3
        end
      end

      projects.sort{|a,b| project_with_priority_order[a.id] <=> project_with_priority_order[b.id]}.each do |project|

        if nb_projects <= 0
          new_version = project.version_number
        else
          new_version = couple_array[3]

          if version_last_number.to_i == 0
            new_version = new_version + ".#{nb_projects}"
            #new_version = new_version + ".#{version_last_number}"

          elsif version_last_number.to_i == 1
            new_version[-1] = "0"
            new_version = new_version + ".#{nb_projects}"
          else
            new_version = project.version_number
            new_version.chop!
            new_version = new_version + "0.#{nb_projects}.#{version_last_number}"
          end

          project.version_number = new_version
          project.save(validate: false)
        end

        nb_projects = nb_projects+1
      end
    end

    add_index :projects, [:organization_id, :is_model, :title, :version_number], unique: true, name: :organization_projects_title_uniqueness unless index_exists?(:projects, [:organization_id, :is_model, :title, :version_number], name: :organization_projects_title_uniqueness)
  end

  def up_save
    # tmp_results = []
    # organizations = Organization.all
    # organizations.each do |organization|
    #   organization.projects.where(is_model: false).each do |project|
    #     tmp_results << "#{organization.id}_#{project.title}_#{project.version_number}"
    #   end
    # end
    #
    # results = tmp_results.find_all{ |e| tmp_results.count(e) > 1 }
    #
    # results.each_with_index do |res, i|
    #   arr = res.split('_')
    #   project = Project.where(organization_id: arr[0], title: arr[1], version_number: arr[2]).first
    #   unless project.nil?
    #
    #     random_string = (0...6).map { ('a'..'z').to_a[rand(26)] }.join
    #
    #     project.version_number = "#{project.version_number}-#{random_string}"
    #     project.save(validate: false)
    #   end
    # end
    end


  def down
    remove_index :projects, name: :organization_projects_title_uniqueness if index_exists?(:projects, [:organization_id, :is_model, :title, :version_number], name: :organization_projects_title_uniqueness)
  end
end
