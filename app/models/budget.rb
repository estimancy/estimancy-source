class Budget < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :start_date, :end_date, :sum, :field_id

  belongs_to :organization
  has_many :budget_types, dependent: :destroy

  def self.fetch_project_field_data(organization, budget, application)
    bt_hash = Hash.new {|h,k| h[k] = [] }

    BudgetTypeStatus.where(application_id: application.id,
                           organization_id: organization.id).all.each do |bts|

      projects = Project.where(application_id: application.id ,
                               organization_id: organization.id,
                               estimation_status_id: bts.estimation_status_id,
                               is_model: false).all
      projects_sum = 0

      projects.each do |project|
        unless budget.field_id.nil?

          field = Field.where(organization_id: project.organization_id, name: Field.find(budget.field_id).name).first
          project_field = ProjectField.where(project_id: project.id, field_id: field.id).first

          unless project_field.nil?
            value = project_field.value
          else
            value = 0
          end

          projects_sum += value.to_f

          unless bts.budget_type.nil?
            bt_hash[bts.budget_type.name] << projects_sum.round(2)
          end
        end
      end
    end
    bt_hash
  end
end
