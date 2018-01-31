module AutorizationLogEventsHelper

  def save_associations_event_changes(item)
    #begin
      #organization_id = @current_organization.id #rescue nil
      what_changes = item._record_changes

      unless what_changes.blank?
        what_changes.each do |class_name, event_changes|
          unless event_changes.empty?
            create_events = event_changes[:create].map(&:id) rescue []
            delete_events = event_changes[:delete].map(&:id) rescue []

            organization_id = (item.event_organization_id || item.organization_id) rescue item.organization_id

            is_project_security = item._is_project_security rescue nil
            is_model_security = item._is_model_security rescue nil
            is_group_security = item._is_group_security rescue nil
            is_security_on_created_from_model = item._is_security_on_created_from_model rescue nil

            project_id = item._project_id rescue nil
            user_id = item._project_id rescue nil
            group_id = item._group_id rescue nil
            project_security_level_id = item._project_security_level_id rescue nil

            if class_name == "ProjectSecurity"

            else

            end

            AutorizationLogEvent.create(organization_id: organization_id,
                                        author_id: item.originator_id,
                                        item_type: "#{class_name.to_s}#{item.class.name.to_s}",
                                        item_id:  item.id,
                                        object_class_name: item.class.name,
                                        association_class_name: class_name,
                                        event: 'update',
                                        object_changes: { create_event: create_events, delete_event: delete_events },
                                        associations_before_changes: item._associations_before_changes,
                                        #associations_after_changes: (item.send("#{class_name.to_s.downcase.pluralize}").map(&:id) rescue []),
                                        associations_after_changes: (item.send("#{class_name.to_s.tableize}").map(&:id) rescue []),
                                        is_project_security: is_project_security,
                                        is_model_security: is_model_security,
                                        is_group_security: is_group_security,
                                        project_id: project_id,
                                        user_id: user_id,
                                        group_id: group_id,
                                        project_security_level_id: project_security_level_id,
                                        is_security_on_created_from_model: is_security_on_created_from_model,
                                        created_at: Time.now())

          end
        end
      end

    #rescue
      # nothing to do
      #puts "Hello"
    #end

  end
end
