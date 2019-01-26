require 'test_helper'

class OrdersheetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ordersheet = ordersheets(:one)
  end

  test "should get index" do
    get ordersheets_url
    assert_response :success
  end

  test "should get new" do
    get new_ordersheet_url
    assert_response :success
  end

  test "should create ordersheet" do
    assert_difference('Ordersheet.count') do
      post ordersheets_url, params: { ordersheet: { amount: @ordersheet.amount, height: @ordersheet.height, width: @ordersheet.width } }
    end

    assert_redirected_to ordersheet_url(Ordersheet.last)
  end

  test "should show ordersheet" do
    get ordersheet_url(@ordersheet)
    assert_response :success
  end

  test "should get edit" do
    get edit_ordersheet_url(@ordersheet)
    assert_response :success
  end

  test "should update ordersheet" do
    patch ordersheet_url(@ordersheet), params: { ordersheet: { amount: @ordersheet.amount, height: @ordersheet.height, width: @ordersheet.width } }
    assert_redirected_to ordersheet_url(@ordersheet)
  end

  test "should destroy ordersheet" do
    assert_difference('Ordersheet.count', -1) do
      delete ordersheet_url(@ordersheet)
    end

    assert_redirected_to ordersheets_url
  end
end
