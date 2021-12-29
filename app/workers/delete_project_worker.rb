class DeleteProjectWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(project_id)
    project = Project.find(project_id)
    project.destroy
  end
end

#Project.select(:organization_id, :is_model, :title, :version_number).group(:organization_id, :is_model, :title, :version_number).having("count(*) > 1").size