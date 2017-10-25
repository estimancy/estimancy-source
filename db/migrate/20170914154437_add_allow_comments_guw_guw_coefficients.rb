class AddAllowCommentsGuwGuwCoefficients < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :allow_comments, :boolean
  end
end
