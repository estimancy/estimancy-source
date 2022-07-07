class AddMathSetToCoefficientElement < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :math_set, :string, default: "R"
  end
end
