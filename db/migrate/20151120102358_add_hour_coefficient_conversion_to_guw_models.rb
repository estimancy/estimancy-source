class AddHourCoefficientConversionToGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :hour_coefficient_conversion, :float
  end
end
