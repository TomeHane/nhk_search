require "test_helper"

class ProgramsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get programs_path
    assert_response :success
  end
end
