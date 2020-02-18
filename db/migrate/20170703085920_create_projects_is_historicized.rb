
class CreateProjectsIsHistoricized < ActiveRecord::Migration

  def up

    unless ActiveRecord::Base.connection.column_exists?('projects', 'is_historicized')
      add_column :projects, :is_historicized, :boolean
    end
  end


  def down
    remove_column :projects, :is_historicized
  end

end


