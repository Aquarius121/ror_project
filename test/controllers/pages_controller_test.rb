require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get localDeals" do
    get :localDeals
    assert_response :success
  end

  test "should get aboutUs" do
    get :aboutUs
    assert_response :success
  end

  test "should get contactUs" do
    get :contactUs
    assert_response :success
  end

end
