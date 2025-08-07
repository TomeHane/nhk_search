require "test_helper"
require "minitest/reporters"
Minitest::Reporters.use!

class ProgramsIndexTest < ActionDispatch::IntegrationTest
  test '番組検索成功' do
    # パラメータ付きGETリクエストを送る
    get programs_path, params: { date: 0, area: "130", genre: "0101", keyword: "甲子園" }
    assert_response :success
    assert_template 'programs/index'                               # programs/indexテンプレートが表示されているか
    assert_select "form[action=?][method=?]", programs_path, "get" # 検索フォームがあるか
    assert_select "h2[class=?]", "date"                            # 日付が表示されているか
  end

  test '番組検索成功：検索結果0件' do
    # 絶対にヒットしない検索ワードを指定
    get programs_path, params: { date: 0, area: "130", genre: "0000", keyword: "hogepiyofoobar" }
    assert_response :success
    assert_template 'programs/index'
    assert_select "h2[class=?]", "date"
    assert_select "p[class=?]", "not_found" # 検索0件のときのメッセージが表示されるか
  end

  test '番組検索成功：全ジャンル、検索ワード空欄' do
    get programs_path, params: { date: 0, area: "130", genre: "all", keyword: "" }
    assert_response :success
    assert_template 'programs/index'
    assert_select "h2[class=?]", "date"
    assert_select "caption[class=?]", "channel", count: 3 # チャンネル名が3つ表示されるか
    assert_select "div[class=?]", "program_time"          # 番組の時間が表示されるか
    assert_select "h3[class=?]" , "program_title"         # 番組名が表示されるか
    assert_select "div[class=?]", "program_content"       # 番組の説明が表示されるか
  end

  test '番組検索失敗' do
    # 不正なパラメータ（date: 8）を指定
    get programs_path, params: { date: 8, area: "130", genre: "all", keyword: "" }
    assert_response :redirect
    follow_redirect!
    assert_template 'home/index'          # home/indexテンプレートが表示されているか
    assert_select "p[class=?]", "warning" # エラーメッセージが表示されるか
  end
end
