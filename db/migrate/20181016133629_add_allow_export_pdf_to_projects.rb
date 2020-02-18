class AddAllowExportPdfToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :allow_export_pdf, :boolean
  end
end