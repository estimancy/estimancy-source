class Guw::GuwAttributeTypesController < ApplicationController

  def edit
    @guw_model = Guw::GuwModel.where(id: params[:guw_model_id]).first
    @guw_type = Guw::GuwType.where(id: params[:guw_type_id]).first
    @guw_attribute_type = Guw::GuwAttributeType.where(id: params[:id]).first
  end

  def update
    @guw_attribute_type = Guw::GuwAttributeType.where(id: params[:id]).first
    @guw_attribute_type.default_value = params[:guw_attribute_type][:default_value]
    @guw_attribute_type.additional_description = params[:guw_attribute_type][:additional_description]
    @guw_attribute_type.save

    redirect_to :back
  end

end
