require 'test_helper'

class ClubTypesControllerTest < ActionController::TestCase
  setup do
    @club_type = club_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:club_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create club_type" do
    assert_difference('ClubType.count') do
      post :create, club_type: { title: @club_type.title }
    end

    assert_redirected_to club_type_path(assigns(:club_type))
  end

  test "should show club_type" do
    get :show, id: @club_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @club_type
    assert_response :success
  end

  test "should update club_type" do
    patch :update, id: @club_type, club_type: { title: @club_type.title }
    assert_redirected_to club_type_path(assigns(:club_type))
  end

  test "should destroy club_type" do
    assert_difference('ClubType.count', -1) do
      delete :destroy, id: @club_type
    end

    assert_redirected_to club_types_path
  end
end
