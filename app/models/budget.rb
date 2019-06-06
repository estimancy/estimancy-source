class Budget < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :start_date, :end_date, :sum, :field_id

  belongs_to :organization

  has_many :budget_budget_types, dependent: :destroy
  has_many :budget_types, through: :budget_budget_types

  has_many :application_budgets, dependent: :destroy
  has_many :applications, through: :application_budgets  #all applications

  has_many :application_budget_types, :foreign_key => 'application_id', :class_name => 'Application', dependent: :destroy
  has_many :used_applications, through: :application_budget_types   #used applications


  def self.fetch_project_field_data(organization, budget, application)
    bt_hash = Hash.new {|h,k| h[k] = [] }
    bt_sum = Hash.new

    #BudgetTypeStatus.where(application_id: application.id, organization_id: organization.id).all.each do |bts|
    ApplicationBudgetType.where(organization_id: organization.id, application_id: application.id, budget_id: budget.id).all.each do |bts|

      projects = Project.where(organization_id: organization.id, application_id: application.id ,  estimation_status_id: bts.estimation_status_id, is_model: false).all
      projects_sum = 0

      projects.each do |project|
        unless budget.field_id.nil?

          field = Field.where(organization_id: project.organization_id, name: Field.find(budget.field_id).name).first
          project_field = ProjectField.where(project_id: project.id, field_id: field.id).first

          unless project_field.nil?
            begin
              value = project_field.value.to_f / field.coefficient
            rescue
              value = 0
            end
          else
            value = 0
          end

          projects_sum += value.to_f

          unless bts.budget_type.nil?
            bt_hash[bts.budget_type.name] << projects_sum.round(2)
          end
        end
      end

      bt_hash.each do |k,v|
        bt_sum[k] = v.sum
      end

    end
    bt_sum
  end

end
