require "test_helper"

class ProgramsControllerTest < ActionDispatch::IntegrationTest
  test "パラメータを付与しないとホームページにリダイレクト" do
    get programs_path
    assert_response :redirect
    assert_redirected_to root_path
  end
end
