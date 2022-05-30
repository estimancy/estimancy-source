class DeletePrefixQuotationNumberToOrganizations < ActiveRecord::Migration
  def up
    remove_column :organizations, :prefix_quotation_number
  end

  def down
    add_column :organizations, :prefix_quotation_number, :string
  end
end
