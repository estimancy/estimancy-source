class DeleteProjectWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(project_id)
    project = Project.find(project_id)
    project.destroy
  end
end