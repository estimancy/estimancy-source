class AddEffortIsModifiableToWbsActivityRatioElements < ActiveRecord::Migration

  def up
    add_column :wbs_activity_ratio_elements, :effort_is_modifiable, :boolean
    add_column :wbs_activity_ratio_elements, :cost_is_modifiable, :boolean

    add_column :wbs_activity_ratios, :comment_required_if_modifiable, :boolean

    if ActiveRecord::Base.connection.column_exists?('wbs_activity_ratio_elements', 'is_modifiable')
      WbsActivityRatioElement.all.each do |elt|
        unless elt.is_modifiable.nil?
          elt.effort_is_modifiable = elt.is_modifiable
          elt.cost_is_modifiable = elt.is_modifiable
          elt.save
        end
      end
    end
  end


  def down
    remove_column :wbs_activity_ratio_elements, :effort_is_modifiable
    remove_column :wbs_activity_ratio_elements, :cost_is_modifiable
  end

end
