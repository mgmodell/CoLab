# frozen_string_literal: true

require 'test_helper'

class ExperiencesControllerTest < ActionController::TestCase
  test 'should get next' do
    get :next
    assert_response :success
  end

  test 'should get diagnose' do
    get :diagnose
    assert_response :success
  end

  test 'should get reaction' do
    get :reaction
    assert_response :success
  end
end
