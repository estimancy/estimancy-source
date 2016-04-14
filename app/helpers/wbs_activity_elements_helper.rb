#encoding: utf-8
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

module WbsActivityElementsHelper

  #Generate wbs activity tree with subtree
  # element : is the root element or the subtree parent or simple wbs_activity_element
  # activity_tree_hash: is an ordered hash
  def generate_activity_as_subtree(element, activity_tree_hash, tree)
    #Root is always display
    tree ||= String.new
    unless element.nil?
      if element.is_root?
        tree << "<ul style='margin-left:1px;' id='tree'>
                   <li style='margin-left:-1px;'>
                    <div class='block_label'>
                        #{show_element_name(element)}
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(element) }
                    </div>
                  </li>"
      end

      if element.has_children?
        tree << "<ul class='sortable'>"
        ###element.children.order("dotted_id ASC").each do |e|
        #element.children.order("position ASC").each do |e|
        unless activity_tree_hash.nil?
          activity_tree_hash.each do |e, children|
            tree << "
                     <li style='margin-left:#{element.depth}px;' >
                      <div class='block_label'>
                        #{show_element_name(e)}
                      </div>
                      <div class='block_link'>
                        #{ link_activity_element(e) }
                      </div>
                    </li>"

            ###generate_activity_element_tree(e, tree)
            generate_activity_as_subtree(e, children, tree)
          end
        end
        tree << '</ul>'
      end
    end
    tree
  end


  #Generate tree of Activity Element (wbs_activities/:id/edit)
  def generate_activity_element_tree(element, tree)
    #Root is always display
    tree ||= String.new
    unless element.nil?
      if element.is_root?
        tree << "<ul style='margin-left:1px;' id='tree'>
                   <li style='margin-left:-1px;'>
                    <div class='block_label'>
                        #{show_element_name(element)}
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(element) }
                    </div>
                  </li>"
      end

      if element.has_children?
        tree << "<ul class='sortable'>"
        element.children.order("dotted_id ASC").each do |e|
          tree << "
                   <li style='margin-left:#{element.depth}px;' >
                    <div class='block_label'>
                      #{show_element_name(e)}
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(e) }
                    </div>
                  </li>"

          generate_activity_element_tree(e, tree)
        end
        tree << '</ul>'
      end
    end
    tree
  end


  #Generate tree of Activity Element (projects/:id/edit and dashboard)
  def generate_wbs_project_elt_tree(element, tree, show_hidden=false, is_project_show_view=false)
    #Root is always display
    gap = 2.5
    tree ||= String.new
    unless element.nil?
      if element.is_root?
        tree << "<ul style='margin-left:1px;' id='tree'>
                   <li style='margin-left:-1px;'>
                    <div class='block_label'>
                        #{ show_element_name(element) }
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(element, is_project_show_view) }
                    </div>
                  </li>"
      end

      if element.has_children?
        tree << "<ul class='sortable'>"
        element.children.each do |e|
          if show_hidden == 'true'
            tree << "
                     <li style='margin-left:-#{gap+element.depth}px;' class='testcolor' >
                      <div class='block_label'>
                        #{show_element_name(e)}
                      </div>
                      <div class='block_link'>
                        #{ link_activity_element(e, is_project_show_view) }
                      </div>
                    </li>"

            generate_wbs_project_elt_tree(e, tree, show_hidden, is_project_show_view)
          else
            unless e.exclude
              tree << "
                       <li style='margin-left:-#{gap+element.depth}px;' class='testcolor' >
                        <div class='block_label'>
                          #{show_element_name(e)}
                        </div>
                        <div class='block_link'>
                          #{ link_activity_element(e, is_project_show_view) }
                        </div>
                      </li>"

              generate_wbs_project_elt_tree(e, tree, show_hidden, is_project_show_view)
            end
          end
        end
        tree << '</ul>'
      end
    end
    tree
  end

  # Show the wbs_activity_element position in front of the name
  def show_element_position(element)
    if element.position.nil?
      "-"
    else
      h "%g" % (element.position)
    end
  end

  def show_element_name(element)
    if element.attributes.has_key? 'record_status_id'
      if element.is_root?
        "<span class='#{h element.record_status.to_s } root_bolder'>#{h element.name} </span>"
      else
        element_wbs_root = element.root
        if params[:wbs_activity_ratio_id]
          element_ratio_value = nil
          strong_class = ""
          corresponding_ratio_element = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? AND wbs_activity_element_id = ?', params[:wbs_activity_ratio_id].to_i, element.id).first
          if !corresponding_ratio_element.nil?
            element_ratio_value = corresponding_ratio_element.ratio_value
            if corresponding_ratio_element.multiple_references == true
              strong_class = "strong"
            end
          end
          "<span class='#{h element.record_status.to_s } #{strong_class}'> #{h element.name} </span> <span class='darkseagreen'>#{corresponding_ratio_element.nil? ? '' : '(' + element_ratio_value.to_s + '%)'}</span> "
        else
          "<span class='#{h element.record_status.to_s }' title='#{I18n.t(:position)} = #{show_element_position(element)}'> #{h element.name} </span>"
        end

      end

    else
      if element.is_root?
        "<span class=''>#{element.pe_wbs_project.name} WBS-Activity</span>"
        #"<span class=''>#{h @project.title} effort breakdown </span>"

      else
        if element.wbs_activity_element.nil? && element.wbs_activity.nil?
          "<span class=''> * #{h element.name} </span>"
        else
          # Get the element (Wbs_project_element) Ratio value
          element_wbs_root = element.ancestors.select{|i| i.is_added_wbs_root}.first
          element_wbs_root_ratio = element_wbs_root.nil? ? nil : element_wbs_root.wbs_activity_ratio
          element_ratio_value = nil
          strong_class = ""
          unless element_wbs_root_ratio.nil?
            element_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? AND wbs_activity_element_id = ?', element_wbs_root_ratio.id, element.wbs_activity_element_id).first
            if !element_ratio_elt.nil?
              element_ratio_value = element_ratio_elt.ratio_value
              if element_ratio_elt.multiple_references == true
                strong_class = "strong"
              end
            end
          end
          if element_ratio_elt.nil?
            "<span class=''> #{h element.name}</span> <span class='darkseagreen'>#{element.wbs_activity_ratio.nil? ? '' : '(' + element.wbs_activity_ratio.name + ')' } </span>"
          else
            "<span class='#{strong_class}'> #{h element.name} </span> <span class='darkseagreen'>#{element_ratio_elt.nil? ? '' : '(' + element_ratio_value.to_s + '%)'}</span>"
          end
        end
      end
    end
  end


  def link_activity_element(element, is_project_show_view=false)
    res = String.new
    unless is_project_show_view
      if element.attributes.has_key? 'record_status_id'
        res << link_to('', new_wbs_activity_element_path(:selected_parent_id => element.id, :activity_id => element.wbs_activity_id), :class => 'button_attribute_tooltip icon-plus pull-left', :title => I18n.t('button_add'))
        res << link_to('', edit_wbs_activity_element_path(element, :activity_id => element.wbs_activity_id), :class => 'button_attribute_tooltip icon-pencil pull-left', :title => I18n.t('edit'))
        res << link_to('', element, confirm: I18n.t('are_you_sure'), method: :delete, :class => 'button_attribute_tooltip icon-trash pull-left', :title => I18n.t('delete'))
      else
        res << link_to_unless(element.cannot_get_new_child_link?, '', new_wbs_project_element_path(:selected_parent_id => element.id, :project_id => @project.id), :class => 'button_attribute_tooltip icon-plus pull-left', :title => I18n.t('button_add'))
        res << link_to_unless(element.is_root?, '', edit_wbs_project_element_path(element, :project_id => @project.id), :class => 'button_attribute_tooltip icon-pencil pull-left', :title => I18n.t('edit'))
        res << link_to_unless(element.is_root?, '', wbs_project_element_path(element, :project_id => @project.id), confirm: I18n.t('are_you_sure'), method: :delete, :project_id => @project.id, :class => 'button_attribute_tooltip icon-trash pull-left', :title => I18n.t('delete')) unless  !element.destroy_leaf
        res << link_to_if(element.is_added_wbs_root, '', "wbs_project_elements/#{element.id}/change_wbs_project_ratio", :wbs_project_element_id => element.id, :project_id => @project.id, :class => 'button_attribute_tooltip icon-share pull-left', :title => I18n.t('change_ratio'), :remote => true)
      end
    end
    res
  end

end
