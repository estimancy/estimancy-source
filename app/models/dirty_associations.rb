# app/models/dirty_associations.rb
module DirtyAssociations
  attr_accessor :dirty
  attr_accessor :_record_changes_create
  attr_accessor :_record_changes_delete
  attr_accessor :_record_changes
  attr_accessor :_associations_before_changes
  attr_accessor :_associations_after_changes

  attr_accessor :_is_project_security
  attr_accessor :_is_model_security
  attr_accessor :_is_group_security
  attr_accessor :_is_security_on_created_from_model

  attr_accessor :_project_id
  attr_accessor :_user_id
  attr_accessor :_group_id
  attr_accessor :_project_security_level_id

  #associations = self.class.reflections.select { |k, v| v.collection? }.keys
  #associations = associations.select { |e| e.in? [:organizations, :groups, :groups_users, :organizations_users] }

  def make_dirty_add(record)
    self.dirty = true

    class_name = record.class.name
    association_name = class_name.tableize

    #self._associations_before_changes ||=  self.previous_changes
    #self._associations_before_changes ||=  self.send("#{class_name.to_s.downcase.pluralize}").map(&:id) - [record.id]
    self._associations_before_changes ||=  self.send(association_name).map(&:id) - [record.id]

    self._record_changes_create ||= []
    self._record_changes_create << record

    self._record_changes ||= {}
    self._record_changes[class_name.to_sym] ||= {}
    self._record_changes[class_name.to_sym][:create] = self._record_changes_create

    self._is_project_security = record.is_estimation_permission rescue nil
    self._is_model_security = record.is_model_permission rescue nil
    self._is_group_security = !record.group_id.blank? rescue nil
    #self._is_security_on_created_from_model = record.is_estimation_permission rescue nil

    self._project_id = record.project_id rescue nil
    self._user_id = record.user_id rescue nil
    self._group_id = record.group_id rescue nil
    self._project_security_level_id = record.project_security_level_id rescue nil

  end

  def make_dirty_remove(record)
    self.dirty = true
    class_name = record.class.name
    association_name = class_name.tableize

    #self._associations_before_changes ||= self.send("#{class_name.to_s.downcase.pluralize}").map(&:id) + [record.id]
    self._associations_before_changes ||= self.send(association_name).map(&:id) + [record.id]

    self._record_changes_delete ||= []
    self._record_changes_delete << record

    self._record_changes ||= {}
    self._record_changes[class_name.to_sym] ||= {}
    self._record_changes[class_name.to_sym][:delete] = self._record_changes_delete

    self._is_project_security = record.is_estimation_permission rescue nil
    self._is_model_security = record.is_model_permission rescue nil
    self._is_group_security = !record.group_id.blank? rescue nil
    #self._is_security_on_created_from_model = record.is_estimation_permission rescue nil

    self._project_id = record.project_id rescue nil
    self._user_id = record.user_id rescue nil
    self._group_id = record.group_id rescue nil
    self._project_security_level_id = record.project_security_level_id rescue nil
  end



  def changed?
    dirty || super
  end

  #### AJOUT

  #### FIn AJOUT
end

# module DirtyAssociations
#   attr_accessor :dirty
#
#   def make_dirty(record)
#     self.dirty = true
#   end
#
#   def changed?
#     dirty || super
#   end
#
#   def after_add rel, callback
#     a = reflect_on_association(rel)
#     send(a.macro, rel, a.options.merge(:after_add => callback))
#   end
#
# end