class AddQuotationNumberToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :automatic_quotation_number, :string, default: 0 unless column_exists?(:organizations, :automatic_quotation_number)
    add_column :projects, :use_automatic_quotation_number, :boolean unless column_exists?(:projects, :use_automatic_quotation_number)
  end
end
