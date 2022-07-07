class AddSummaryResultsToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :summary_results, :text
  end
end
