require 'test_helper'

module Operation
  class OperationInputsControllerTest < ActionController::TestCase
    setup do
      @operation_input = operation_inputs(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:operation_inputs)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create operation_input" do
      assert_difference('OperationInput.count') do
        post :create, operation_input: { name: @operation_input.name, operation_model_id: @operation_input.operation_model_id, standard_coefficient: @operation_input.standard_coefficient }
      end
  
      assert_redirected_to operation_input_path(assigns(:operation_input))
    end
  
    test "should show operation_input" do
      get :show, id: @operation_input
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @operation_input
      assert_response :success
    end
  
    test "should update operation_input" do
      put :update, id: @operation_input, operation_input: { name: @operation_input.name, operation_model_id: @operation_input.operation_model_id, standard_coefficient: @operation_input.standard_coefficient }
      assert_redirected_to operation_input_path(assigns(:operation_input))
    end
  
    test "should destroy operation_input" do
      assert_difference('OperationInput.count', -1) do
        delete :destroy, id: @operation_input
      end
  
      assert_redirected_to operation_inputs_path
    end
  end
end
