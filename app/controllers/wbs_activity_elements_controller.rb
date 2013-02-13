class WbsActivityElementsController < ApplicationController
  include PeWbsHelper
  include DataValidationHelper #Module for master data changes validation

  helper_method :wbs_record_statuses_collection

  before_filter :get_record_statuses

  def new
    set_page_title "WBS-Activity elements"
    @wbs_activity_element = WbsActivityElement.new

    if params[:activity_id]
      @wbs_activity = WbsActivity.find(params[:activity_id])
      @potential_parents = @wbs_activity.wbs_activity_elements
    end

    @selected_parent ||= WbsActivityElement.find_by_id(params[:selected_parent_id])

  end

  def edit
    set_page_title "WBS-Activity elements"
    @wbs_activity_element = WbsActivityElement.find(params[:id])

    if params[:activity_id]
      @wbs_activity = WbsActivity.find(params[:activity_id])
      if @wbs_activity_element.ancestry.nil?
        @potential_parents = []
      else
        @potential_parents = @wbs_activity.wbs_activity_elements
      end
    end

    @selected_parent = @wbs_activity_element.parent

    if is_master_instance?
      unless @wbs_activity_element.child_reference.nil?
        if @wbs_activity_element.child_reference.is_proposed_or_custom?
          flash[:notice] = "This Wbs-Activity element can't be edited, previous changes have not yet been validated."
          redirect_to wbs_activity_element_path(@wbs_activity_element.wbs_activity) and return
        end
      end
    else
      if @wbs_activity_element.is_local_record?
        @wbs_activity_element.record_status = @local_status
      else
        flash[:error] = "Master record can not be deleted, it is required for the proper functioning of the application"
        redirect_to wbs_activity_element_path(@wbs_activity.id)
      end
    end
  end

  def create
    @wbs_activity_element = WbsActivityElement.new(params[:wbs_activity_element])

    @selected = @wbs_activity_element.parent
    @wbs_activity = @wbs_activity_element.wbs_activity

    #If we are on local instance, Status is set to "Local"
    if is_master_instance?   #so not on master
      @wbs_activity_element.record_status = @proposed_status
    else
      @wbs_activity_element.record_status = @local_status
    end

    if @wbs_activity_element.save
      @wbs_activity.wbs_activity_ratios.each do |wbs_activity_ratio|
        @wbs_activity_ratio_element = WbsActivityRatioElement.create(:ratio_value => nil,
                                                                     :ratio_reference_element => false,
                                                                     :wbs_activity_ratio_id => wbs_activity_ratio.id,
                                                                     :wbs_activity_element_id => @wbs_activity_element.id)
      end
      redirect_to edit_wbs_activity_path(@wbs_activity), notice: 'Wbs activity element was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @wbs_activity_element = nil
    current_wbs_activity_element = WbsActivityElement.find(params[:id])

    @wbs_activity ||= WbsActivity.find_by_id(params[:activity_id])
    @potential_parents = @wbs_activity.wbs_activity_elements if @wbs_activity
    @selected_parent = current_wbs_activity_element

    if current_wbs_activity_element.is_defined?
      @wbs_activity_element = current_wbs_activity_element.amoeba_dup
      @wbs_activity_element.owner_id = current_user.id
    else
      @wbs_activity_element = current_wbs_activity_element
    end

    unless is_master_instance?
      if @wbs_activity_element.is_local_record?
        @wbs_activity_element.custom_value = "Locally edited"
      end
    end

    if params[:wbs_activity_element][:wbs_activity_id]
      @wbs_activity = WbsActivity.find(params[:wbs_activity_element][:wbs_activity_id])
    end

    if @wbs_activity_element.update_attributes(params[:wbs_activity_element])
      redirect_to edit_wbs_activity_path(@wbs_activity), notice: 'Wbs activity element was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @wbs_activity_element = WbsActivityElement.find(params[:id])

    #@wbs_activity_element.destroy
    if is_master_instance?
      if @wbs_activity_element.is_defined? || @wbs_activity_element.is_custom?
        #logical deletion  delete don't have to suppress records anymore on Defined record
        @wbs_activity_element.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      else
        @wbs_activity_element.destroy
      end
    else
      if @wbs_activity_element.is_local_record? || @wbs_activity_element.is_retired?
        @wbs_activity_element.destroy
      else
        flash[:error] = "Master record can not be deleted, it is required for the proper functioning of the application"
        redirect_to edit_wbs_activity_path(@wbs_activity)  and return
      end
    end

    redirect_to edit_wbs_activity_path(@wbs_activity_element.wbs_activity)
  end

  def wbs_record_statuses_collection
    if @wbs_activity.new_record?
      if is_master_instance?
        @wbs_record_status_collection = RecordStatus.where("name = ?", "Proposed")
      else
        @wbs_record_status_collection = RecordStatus.where("name = ?", "Local")
      end
    else
      @wbs_record_status_collection = []
      if @wbs_activity.is_defined?
        @wbs_record_status_collection = RecordStatus.where("name = ?", "Defined")
      else
        @wbs_record_status_collection = RecordStatus.where("name <> ?", "Defined")
      end
    end
  end

end
