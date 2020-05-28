class CreateIndexOrganizationProjectsTitleUniqueness < ActiveRecord::Migration

  def up

    tmp_results = []
    organizations = Organization.all
    organizations.each do |organization|
      organization.projects.where(is_model: false).each do |project|
        tmp_results << "#{organization.id}_#{project.title}_#{project.version_number}"
      end
    end

    results = tmp_results.find_all{ |e| tmp_results.count(e) > 1 }

    results.each_with_index do |res, i|
      arr = res.split('_')
      project = Project.where(organization_id: arr[0], title: arr[1], version_number: arr[2]).first
      unless project.nil?

        random_string = (0...6).map { ('a'..'z').to_a[rand(26)] }.join

        project.version_number = "#{project.version_number}-#{random_string}"
        project.save(validate: false)
      end
    end

    add_index :projects, [:organization_id, :is_model, :version_number, :title], unique: true, name: :organization_projects_title_uniqueness unless index_exists?(:projects, [:organization_id, :is_model, :version_number, :title], name: :organization_projects_title_uniqueness)
  end


  def down
    remove_index :projects, name: :organization_projects_title_uniqueness if index_exists?(:projects, [:organization_id, :is_model, :version_number, :title], name: :organization_projects_title_uniqueness)
  end
end
