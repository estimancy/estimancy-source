class AddModuleProjectIdToGuwGuwCoefficientElementUnitOfWorks < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_coefficient_element_unit_of_works, :module_project_id, :integer
    rescue
    end
  end
end
