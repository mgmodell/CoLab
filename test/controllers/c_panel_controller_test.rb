require 'test_helper'

class CPanelControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get c_panel_index_url
    assert_response :success
  end

end
