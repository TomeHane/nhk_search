require "test_helper"
# テスト結果に色が付くようにする
require "minitest/reporters"
Minitest::Reporters.use!

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'ホーム画面のレイアウト' do
    # rootにアクセス
    get root_path
    # indexテンプレートが表示されているか
    assert_template 'home/index'
    # root_pathへのリンクが2つあるか
    assert_select 'a[href=?]', root_path, count: 2

    # /programs (=> programs#index) にGETリクエストを送るフォームがあるか
    assert_select "form[action=?][method=?]", programs_path, "get" do
      # name="date"のselectタグがあるか
      assert_select "select[name=?]", "date"
      # 選択肢に「一週間」があるか
      assert_select "select[name=?] option", "date", text: "一週間"
      # 選択肢に「m月d日(w)」があるか
      assert_select "select[name=?] option", "date", text: /\d{1,2}月\d{1,2}日\([日月火水木金土]\)/
      assert_select "select[name=?]", "area"
      assert_select "select[name=?] option", "area", text: "東京"
      assert_select "select[name=?]", "genre"
      assert_select "select[name=?] option", "genre", text: "すべて"
      assert_select "select[name=?] option", "genre", text: "アニメ"
      # name="keyword"のテキストフィールドがあるか
      assert_select "input[type=text][name=?]", "keyword"
      # 送信ボタンがあるか
      assert_select "button[type=submit]"
    end

  end
end
