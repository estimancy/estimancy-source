class UpdateHideWbsHeaderOfWbsActivity < ActiveRecord::Migration

  def up
    change_column :wbs_activities, :hide_wbs_header, :string

    WbsActivity.all.each do |wbs_activity|
      case wbs_activity.hide_wbs_header.to_s
        when "0", ""
          wbs_activity.hide_wbs_header = "show_all"
        when "1"
          wbs_activity.hide_wbs_header = "hide_all"
      end
      wbs_activity.save
    end
  end

  def down
    change_column :wbs_activities, :hide_wbs_header, :boolean
  end

end
