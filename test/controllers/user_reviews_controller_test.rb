require "test_helper"

class UserReviewsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_reviews_index_url
    assert_response :success
  end
end
