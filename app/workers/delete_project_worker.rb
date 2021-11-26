class DeleteProjectWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(project_id)
    project = Project.find(project_id)
    project.destroy
  end
end