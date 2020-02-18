class AddPositionToWbsActivityElements < ActiveRecord::Migration

  def up
    add_column :wbs_activity_elements, :position, :float

    WbsActivityElement.all.each do |elt|
      unless elt.dotted_id.nil?
        unless elt.dotted_id.empty?
          elt.position = elt.dotted_id.to_f
          elt.save
        end
      end
    end
  end

  def down
    remove_column :wbs_activity_elements, :position
  end

end
