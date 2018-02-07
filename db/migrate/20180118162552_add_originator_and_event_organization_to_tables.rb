class AddOriginatorAndEventOrganizationToTables < ActiveRecord::Migration
  def change
    # Ajouter "originator_id" à toutes les tables qu'on surveille
    add_column :groups, :originator_id, :integer
    add_column :groups, :event_organization_id, :integer

    add_column :users, :originator_id, :integer    #Pas d'organization_id
    add_column :users, :event_organization_id, :integer    #Pas d'organization_id

    add_column :organizations_users, :originator_id, :integer
    add_column :organizations_users, :event_organization_id, :integer
    add_column :organizations_users, :created_at, :datetime
    add_column :organizations_users, :update_at, :datetime

    add_column :groups_users, :originator_id, :integer
    add_column :groups_users, :event_organization_id, :integer

    add_column :project_securities, :originator_id, :integer
    add_column :project_securities, :event_organization_id, :integer

    add_column :project_security_levels, :originator_id, :integer
    add_column :project_security_levels, :event_organization_id, :integer

    add_column :permissions_project_security_levels, :originator_id, :integer
    add_column :permissions_project_security_levels, :event_organization_id, :integer

    add_column :estimation_status_group_roles, :originator_id, :integer
    add_column :estimation_status_group_roles, :event_organization_id, :integer

    add_column :groups_permissions, :originator_id, :integer
    add_column :groups_permissions, :event_organization_id, :integer

    add_column :groups_projects, :originator_id, :integer
    add_column :groups_projects, :event_organization_id, :integer

    add_column :projects, :originator_id, :integer
    add_column :projects, :event_organization_id, :integer


    # add transaction_id
    add_column :users, :transaction_id, :text
    add_column :groups, :transaction_id, :text
    add_column :projects, :transaction_id, :text
    add_column :permissions, :transaction_id, :text
    add_column :project_security_levels, :transaction_id, :text
    add_column :estimation_statuses, :transaction_id, :text

    add_column :groups_users, :transaction_id, :text
    add_column :groups_permissions, :transaction_id, :text
    add_column :groups_projects, :transaction_id, :text
    add_column :organizations_users, :transaction_id, :text
    add_column :permissions_project_security_levels, :transaction_id, :text
    add_column :estimation_status_group_roles, :transaction_id, :text
    add_column :project_securities, :transaction_id, :text


    # remplir les valeurs dans les tables de bases
    User.all.each do |user|
      user.transaction_id = "#{user.id}_1"
      user.save
    end

    Group.all.each do |group|
      group.transaction_id = "#{group.id}_1"
      group.save
    end

    Project.all.each do |project|
      project.transaction_id = "#{project.id}_1"
      project.save
    end

    EstimationStatus.all.each do |es|
      es.transaction_id = "#{es.id}_1"
      es.save
    end

    Permission.all.each do |ps|
      ps.transaction_id = "#{ps.id}_1"
      ps.save
    end

    ProjectSecurityLevel.all.each do |psl|
      psl.transaction_id = "#{psl.id}_1"
      psl.save
    end

  end
end
