
# module Operation
#   class OperationInputsController < ApplicationController
class Operation::OperationInputsController < ApplicationController

    def index
      @operation_model = Operation::OperationModel.find(params[:operation_model_id])
      @operation_inputs = @operation_model.operation_inputs
      set_page_title I18n.t(:output)
    end
  

    def new
      @operation_input = Operation::OperationInput.new
      @operation_model = Operation::OperationModel.find(params[:operation_model_id])
      @organization = @current_organization #Organization.find(params[:organization_id])

      set_page_title "New"

      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params",
                      @organization.to_s => main_app.organization_estimations_path(@organization),
                      I18n.t(:operation_modules) => main_app.organization_module_estimation_path(@organization.id, anchor: "effort"),
                      @operation_model => operation.edit_operation_model_path(@operation_model, organization_id: @organization.id),
                      I18n.t(:new_input_attribute) => ""

    end


    def edit
      @operation_input = Operation::OperationInput.find(params[:id])
      @operation_model = @operation_input.operation_model
      @organization = @current_organization

      set_page_title "Edit"

      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params",
                      @organization.to_s => main_app.organization_estimations_path(@organization),
                      I18n.t(:operation_modules) => main_app.organization_module_estimation_path(@organization.id, anchor: "effort"),
                      @operation_model => operation.edit_operation_model_path(@operation_model, organization_id: @organization.id),
                      @operation_input => operation.edit_operation_model_operation_input_path(@operation_model, @operation_input, organization_id: @organization.id)
    end
  

    def create
      @operation_input = Operation::OperationInput.new(params[:operation_input])
      @operation_model = Operation::OperationModel.find(params[:operation_model_id])
      @organization = @current_organization

      set_page_title "Edit"
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params",
                      @organization.to_s => main_app.organization_estimations_path(@organization),
                      I18n.t(:operation_modules) => main_app.organization_module_estimation_path(@organization.id, anchor: "effort"),
                      @operation_model => operation.edit_operation_model_path(@operation_model, organization_id: @organization.id),
                      I18n.t(:new_input_attribute) => ""

      ActiveRecord::Base.transaction do
        if @operation_input.save

          description = @operation_input.description.nil? ? @operation_input.name : @operation_input.description

          attr = PeAttribute.where(name: @operation_input.name,
                                   alias: @operation_input.name.underscore.gsub(" ", "_"),
                                   description: description,
                                   operation_input_id: @operation_input.id,
                                   operation_model_id: @operation_input.operation_model_id).first_or_create!

          pm = Pemodule.where(alias: "operation").first

          am = AttributeModule.where(pe_attribute_id: attr.id,
                                     pemodule_id: pm.id,
                                     in_out: @operation_input.in_out,
                                     operation_model_id: @operation_input.operation_model_id).first_or_create!

          redirect_to operation.edit_operation_model_path(@operation_input.operation_model_id, organization_id: @organization.id, anchor: "tabs-2")
        else
          render action: "new"
        end
      end

    end
  
    # PUT /operation_inputs/1
    # PUT /operation_inputs/1.json
    def update
      @operation_input = Operation::OperationInput.find(params[:id])
      @operation_model = @operation_input.operation_model
      @organization = @current_organization

      set_page_title "Edit"

      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params",
                      @organization.to_s => main_app.organization_estimations_path(@organization),
                      I18n.t(:operation_modules) => main_app.organization_module_estimation_path(@organization.id, anchor: "effort"),
                      @operation_model => operation.edit_operation_model_path(@operation_model, organization_id: @organization.id),
                      @operation_input => operation.edit_operation_model_operation_input_path(@operation_model, @operation_input, organization_id: @organization.id)

      ActiveRecord::Base.transaction do

        old_attr_name = @operation_input.name

        if @operation_input.update_attributes(params[:operation_input])

          description = @operation_input.description.nil? ? @operation_input.name : @operation_input.description
          pm = Pemodule.where(alias: "operation").first
          old_attr = PeAttribute.where(name: old_attr_name, operation_model_id: @operation_model.id).first

          if old_attr.nil?

            at = PeAttribute.create(name: @operation_input.name,
                                    alias: @operation_input.name.underscore.gsub(" ", "_"),
                                    description: description,
                                    operation_input_id: @operation_input.id,
                                    operation_model_id: @operation_model.id)

            am = AttributeModule.create(pe_attribute_id: at.id,
                                        pemodule_id: pm.id,
                                        in_out: @operation_input.in_out,
                                        operation_model_id: @operation_model.id)
          else

            old_attr.name = @operation_input.name
            old_attr.alias = @operation_input.name.underscore.gsub(" ", "_")
            old_attr.description = description
            old_attr.operation_model_id = @operation_model.id
            old_attr.operation_input_id = @operation_input.id

            if old_attr.save
              old_attr.estimation_values.each do |ev|
                ev.string_data_low[:pe_attribute_name] = @operation_input.name
                ev.string_data_most_likely[:pe_attribute_name] = @operation_input.name
                ev.string_data_high[:pe_attribute_name] = @operation_input.name
                ev.pe_attribute_id = old_attr.id
                ev.save
              end

              am = AttributeModule.where(pe_attribute_id: old_attr.id,
                                         pemodule_id: pm.id,
                                         operation_model_id: @operation_input.operation_model_id).first_or_create

              am.save
            end
          end

          #@operation_model.save

          set_page_title I18n.t(:outputs)
          redirect_to operation.edit_operation_model_path(@operation_model.id, organization_id: @organization.id, anchor: "tabs-2")
        else
          render action: "edit"
        end

      end
    end


    def destroy
      @operation_input = Operation::OperationInput.find(params[:id])
      @operation_model = @operation_input.operation_model
      operation_input_name = @operation_input.name
      attributes = PeAttribute.where(operation_input_id: @operation_input.id).all  #attributes = PeAttribute.where(alias: operation_input_name.underscore.gsub(" ", "_")).all

      ActiveRecord::Base.transaction do

        @operation_input.destroy

        #begin
          attributes.each do |attr|
            pm = Pemodule.where(alias: "operation").first
            AttributeModule.where(pe_attribute_id: attr.id, pemodule_id: pm.id, operation_model_id: @operation_model.id).all.each do |am|
              am.delete
            end
            attr.delete
          end
        #rescue
        #end
      end

      redirect_to operation.edit_operation_model_path(@operation_model, anchor: "tabs-2")
    end
  end
#end
