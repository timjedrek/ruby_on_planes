require "test_helper"

class StatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get states_index_url
    assert_response :success
  end

  test "should get show" do
    get states_show_url
    assert_response :success
  end
end
