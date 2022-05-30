# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class AddCopyIdToGuwGuwModels < ActiveRecord::Migration
  def change
    # for instance modules
    add_column :guw_guw_models, :copy_id, :integer
    add_column :ge_ge_models, :copy_id, :integer
    add_column :expert_judgement_instances, :copy_id, :integer
    add_column :wbs_activities, :copy_id, :integer, after: :copy_number
    add_column :guw_guw_types, :copy_id, :integer
    ###add_column :guw_guw_type_complexities, :copy_id, :integer
    add_column :guw_guw_attributes, :copy_id, :integer
    add_column :guw_guw_work_units, :copy_id, :integer
    add_column :organization_technologies, :copy_id, :integer
    add_column :organization_profiles, :copy_id, :integer
    add_column :wbs_activity_ratios, :copy_id, :integer


    #Remove index
    remove_index(:wbs_activities, :name => 'index_wbs_activities_on_uuid')
    remove_index(:wbs_activities, :name => 'index_wbs_activities_on_record_status_id')
    remove_index(:wbs_activities, :name => 'index_wbs_activities_on_reference_id')

    remove_index(:wbs_activity_elements, :name => 'index_wbs_activity_elements_on_uuid')
    remove_index(:wbs_activity_elements, :name => 'index_wbs_activity_elements_on_record_status_id')
    remove_index(:wbs_activity_elements, :name => 'index_wbs_activity_elements_on_reference_id')

    remove_index(:wbs_activity_ratios, :name => 'index_wbs_activity_ratios_on_uuid')
    remove_index(:wbs_activity_ratios, :name => 'index_wbs_activity_ratios_on_record_status_id')
    remove_index(:wbs_activity_ratios, :name => 'index_wbs_activity_ratios_on_reference_id')

    remove_index(:wbs_activity_ratio_elements, :name => 'index_wbs_activity_ratio_elements_on_uuid')
    remove_index(:wbs_activity_ratio_elements, :name => 'index_wbs_activity_ratio_elements_on_record_status_id')
    remove_index(:wbs_activity_ratio_elements, :name => 'index_wbs_activity_ratio_elements_on_reference_id')

  end
end
