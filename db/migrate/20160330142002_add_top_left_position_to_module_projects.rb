class AddTopLeftPositionToModuleProjects < ActiveRecord::Migration

  def up

    rename_column :projects, :version, :version_number

    add_column :module_projects, :top_position, :float, after: :position_y
    add_column :module_projects, :left_position, :float, after: :top_position
    add_column :module_projects, :creation_order, :integer, after: :left_position

    # copy position_y value in the creation_order attribute
    Project.all.each do |project|
      Pemodule.all.each do |pemodule|
        project.module_projects.where(pemodule_id: pemodule.id).all.each_with_index do |module_project, index|
          module_project.creation_order = index+1
          module_project.save(validate: false)
        end
      end
    end

  end

  def down
    remove_column :module_projects, :top_position
    remove_column :module_projects, :left_position
    remove_column :module_projects, :creation_order
  end

end
