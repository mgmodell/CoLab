# frozen_string_literal: true

require 'test_helper'

class ConsentFormsControllerTest < ActionController::TestCase
  setup do
    @consent_form = consent_forms(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:consent_forms)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create consent_form' do
    assert_difference('ConsentForm.count') do
      post :create, consent_form: {}
    end

    assert_redirected_to consent_form_path(assigns(:consent_form))
  end

  test 'should show consent_form' do
    get :show, id: @consent_form
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @consent_form
    assert_response :success
  end

  test 'should update consent_form' do
    patch :update, id: @consent_form, consent_form: {}
    assert_redirected_to consent_form_path(assigns(:consent_form))
  end

  test 'should destroy consent_form' do
    assert_difference('ConsentForm.count', -1) do
      delete :destroy, id: @consent_form
    end

    assert_redirected_to consent_forms_path
  end
end
