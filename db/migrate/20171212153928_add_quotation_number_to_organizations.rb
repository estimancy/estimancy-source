class AddQuotationNumberToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :automatic_quotation_number, :string, default: 0
    add_column :projects, :use_automatic_quotation_number, :boolean
  end
end
