class WbsActivityRatioVariablesController < ApplicationController
  before_filter :set_wbs_activity_ratio_variable, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @wbs_activity_ratio_variables = WbsActivityRatioVariable.all
    respond_with(@wbs_activity_ratio_variables)
  end

  def show
    respond_with(@wbs_activity_ratio_variable)
  end

  def new
    @wbs_activity_ratio_variable = WbsActivityRatioVariable.new
    respond_with(@wbs_activity_ratio_variable)
  end

  def edit
  end

  def create
    @wbs_activity_ratio_variable = WbsActivityRatioVariable.new(params[:wbs_activity_ratio_variable])
    @wbs_activity_ratio_variable.save
    respond_with(@wbs_activity_ratio_variable)
  end

  def update
    @wbs_activity_ratio_variable.update_attributes(params[:wbs_activity_ratio_variable])
    respond_with(@wbs_activity_ratio_variable)
  end

  def destroy
    @wbs_activity_ratio_variable.destroy
    respond_with(@wbs_activity_ratio_variable)
  end

  private
    def set_wbs_activity_ratio_variable
      @wbs_activity_ratio_variable = WbsActivityRatioVariable.find(params[:id])
    end
end
