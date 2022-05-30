class CreateModuleProjectRatioElements < ActiveRecord::Migration

  def change
    create_table :module_project_ratio_elements do |t|

      t.integer :pbs_project_element_id
      t.integer :module_project_id
      t.integer :wbs_activity_ratio_id
      t.integer :wbs_activity_ratio_element_id
      t.integer :wbs_activity_element_id
      t.boolean :multiple_references

      t.string  :name
      t.text    :description
      t.float   :ratio_value

      t.float   :theoretical_effort_probable
      t.float   :theoretical_cost_probable
      t.float   :retained_effort_probable
      t.float   :retained_cost_probable

      t.text    :comments

      t.float   :theoretical_effort_low
      t.float   :theoretical_effort_high
      t.float   :theoretical_effort_most_likely

      t.float   :theoretical_cost_low
      t.float   :theoretical_cost_high
      t.float   :theoretical_cost_most_likely

      t.float   :retained_effort_low
      t.float   :retained_effort_high
      t.float   :retained_effort_most_likely

      t.float   :retained_cost_low
      t.float   :retained_cost_high
      t.float   :retained_cost_most_likely


      t.integer :copy_id
      t.float   :position
      t.boolean :flagged
      t.boolean :selected

      t.timestamps
    end

    add_column :wbs_activity_ratios, :allow_modify_retained_effort, :boolean
    add_column :wbs_activity_ratios, :allow_modify_ratio_value, :boolean
    add_column :wbs_activity_ratios, :allow_modify_ratio_reference, :boolean
    add_column :wbs_activity_ratios, :allow_add_new_phase, :boolean
  end

end
