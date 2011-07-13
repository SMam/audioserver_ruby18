require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  setup do
    @patient = patients(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patients)
  end

  #test "should get new" do
  #  get :new
  #  assert_response :success
  #end

  #test "should create patient" do
  #  assert_difference('Patient.count') do
  #    post :create, :patient => @patient.attributes
  #  end

  #  assert_redirected_to patient_path(assigns(:patient))
  #end

  test "should show patient" do
    get :show, :id => @patient.to_param
    #assert_response :success
    assert_response 302 # しばらくaudiogramへのredirectとする
  end

  #test "should get edit" do
  #  get :edit, :id => @patient.to_param
  #  assert_response :success
  #end

  #test "should update patient" do
  #  put :update, :id => @patient.to_param, :patient => @patient.attributes
  #  assert_redirected_to patient_path(assigns(:patient))
  #end

  test "should destroy patient" do
    assert_difference('Patient.count', -1) do
      delete :destroy, :id => @patient.to_param
    end

    assert_redirected_to patients_path
  end

  test "should directry create audiogram" do
    testdata = String.new
    testdata << 2
    testdata << <<STR
7@/          /  080604  //   0   30 ,  10   35 ,  20   40 ,          ,  30   4\
5 ,          ,  40   50 ,          ,  50   55 ,          ,  60   60 ,          ,\
 -10   55 ,  -5   55 ,          ,   0   55 ,          ,   5   55 ,          ,  1\
0   55 ,          ,  15   55 ,  4>  4<,  4>  4<,  4>  4<,        ,  4>  4<,     \
   ,  4>  4<,        ,  4>  4<,        ,  4>  4<,        ,  4>  4<,  4>  4<,    \
    ,  4>  4<,        ,  4>  4<,        ,  4>  4<,        ,  4>  4<,/P
STR
    assert_difference('Audiogram.count') do
      get :direct_create, {:hp_id => "0", :examdate => "2008:09:27-12:50:00", :data => testdata}
      #post?? :direct_create, {:hp_id => "0", :examdate => "2008:09:27-12:50:00", :data => testdata}
    end

    assert_response 201
  end

end
