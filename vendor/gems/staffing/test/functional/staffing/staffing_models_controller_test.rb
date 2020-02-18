require 'test_helper'

module Staffing
  class StaffingModelsControllerTest < ActionController::TestCase
    setup do
      @staffing_model = staffing_models(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:staffing_models)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create staffing_model" do
      assert_difference('StaffingModel.count') do
        post :create, staffing_model: { coeff_n: @staffing_model.coeff_n, coefficient: @staffing_model.coefficient, copy_id: @staffing_model.copy_id, copy_number: @staffing_model.copy_number, enabled_input: @staffing_model.enabled_input, name: @staffing_model.name, organization_id: @staffing_model.organization_id, three_points_estimation: @staffing_model.three_points_estimation }
      end
  
      assert_redirected_to staffing_model_path(assigns(:staffing_model))
    end
  
    test "should show staffing_model" do
      get :show, id: @staffing_model
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @staffing_model
      assert_response :success
    end
  
    test "should update staffing_model" do
      put :update, id: @staffing_model, staffing_model: { coeff_n: @staffing_model.coeff_n, coefficient: @staffing_model.coefficient, copy_id: @staffing_model.copy_id, copy_number: @staffing_model.copy_number, enabled_input: @staffing_model.enabled_input, name: @staffing_model.name, organization_id: @staffing_model.organization_id, three_points_estimation: @staffing_model.three_points_estimation }
      assert_redirected_to staffing_model_path(assigns(:staffing_model))
    end
  
    test "should destroy staffing_model" do
      assert_difference('StaffingModel.count', -1) do
        delete :destroy, id: @staffing_model
      end
  
      assert_redirected_to staffing_models_path
    end
  end
end
