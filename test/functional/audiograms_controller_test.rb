require 'test_helper'

class AudiogramsControllerTest < ActionController::TestCase
  setup do
    @patient = patients(:one)
    @audiogram = audiograms(:one)
    @audiogram.patient_id = @patient.id
  end

  test "should get index" do
    get :index, :patient_id => @patient.id
    assert_response :success
    assert_not_nil assigns(:audiograms)
  end

  #test "should get new" do
  #  get :new, :patient_id => @patient.id
  #  assert_response :success
  #end

  #test "should create audiogram" do
  #  assert_difference('Audiogram.count') do
  #    post :create, :audiogram => @audiogram.attributes, :patient_id => @patient.id
  #  end

  #  assert_redirected_to patient_audiogram_path(assigns(:audiogram))
  #end

  test "should show audiogram" do
    get :show, :id => @audiogram.to_param, :patient_id => @patient.id
    assert_response :success
  end

  #test "should get edit" do
  #  get :edit, :id => @audiogram.to_param, :patient_id => @patient.id
  #  assert_response :success
  #end

  #test "should update patient" do
  #  put :update, :id => @audiogram.to_param, :audiogram => @audiogram.attributes, :patient_id => @patient.id
  #  assert_redirected_to patient_audiogram_path(assigns(:audiogram))
  #end

end
