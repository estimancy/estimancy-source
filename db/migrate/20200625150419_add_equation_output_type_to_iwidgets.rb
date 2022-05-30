class AddEquationOutputTypeToIwidgets < ActiveRecord::Migration
  def change
    add_column :iwidgets, :equation_output_type, :string, after: :equation
  end
end
