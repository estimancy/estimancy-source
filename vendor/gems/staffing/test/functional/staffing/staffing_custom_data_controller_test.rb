require 'test_helper'

module Staffing
  class StaffingCustomDataControllerTest < ActionController::TestCase
    setup do
      @staffing_custom_datum = staffing_custom_data(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:staffing_custom_data)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create staffing_custom_datum" do
      assert_difference('StaffingCustomDatum.count') do
        post :create, staffing_custom_datum: { coef_a: @staffing_custom_datum.coef_a, coef_a_prime: @staffing_custom_datum.coef_a_prime, coef_b: @staffing_custom_datum.coef_b, coef_b_prime: @staffing_custom_datum.coef_b_prime, max_duration: @staffing_custom_datum.max_duration, max_staffing: @staffing_custom_datum.max_staffing, method: @staffing_custom_datum.method, period_unit: @staffing_custom_datum.period_unit, staffing_constraint: @staffing_custom_datum.staffing_constraint, staffing_coordinates: @staffing_custom_datum.staffing_coordinates }
      end
  
      assert_redirected_to staffing_custom_datum_path(assigns(:staffing_custom_datum))
    end
  
    test "should show staffing_custom_datum" do
      get :show, id: @staffing_custom_datum
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @staffing_custom_datum
      assert_response :success
    end
  
    test "should update staffing_custom_datum" do
      put :update, id: @staffing_custom_datum, staffing_custom_datum: { coef_a: @staffing_custom_datum.coef_a, coef_a_prime: @staffing_custom_datum.coef_a_prime, coef_b: @staffing_custom_datum.coef_b, coef_b_prime: @staffing_custom_datum.coef_b_prime, max_duration: @staffing_custom_datum.max_duration, max_staffing: @staffing_custom_datum.max_staffing, method: @staffing_custom_datum.method, period_unit: @staffing_custom_datum.period_unit, staffing_constraint: @staffing_custom_datum.staffing_constraint, staffing_coordinates: @staffing_custom_datum.staffing_coordinates }
      assert_redirected_to staffing_custom_datum_path(assigns(:staffing_custom_datum))
    end
  
    test "should destroy staffing_custom_datum" do
      assert_difference('StaffingCustomDatum.count', -1) do
        delete :destroy, id: @staffing_custom_datum
      end
  
      assert_redirected_to staffing_custom_data_path
    end
  end
end
