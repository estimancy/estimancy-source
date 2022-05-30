class AddPrefixQuotationNumberToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :prefix_quotation_number, :string
  end
end
