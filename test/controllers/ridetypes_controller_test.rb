require 'test_helper'

class RidetypesControllerTest < ActionController::TestCase
  setup do
    @ridetype = ridetypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ridetypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ridetype" do
    assert_difference('Ridetype.count') do
      post :create, ridetype: { title: @ridetype.title }
    end

    assert_redirected_to ridetype_path(assigns(:ridetype))
  end

  test "should show ridetype" do
    get :show, id: @ridetype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ridetype
    assert_response :success
  end

  test "should update ridetype" do
    patch :update, id: @ridetype, ridetype: { title: @ridetype.title }
    assert_redirected_to ridetype_path(assigns(:ridetype))
  end

  test "should destroy ridetype" do
    assert_difference('Ridetype.count', -1) do
      delete :destroy, id: @ridetype
    end

    assert_redirected_to ridetypes_path
  end
end
