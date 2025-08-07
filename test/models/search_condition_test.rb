require "test_helper"

class SearchConditionTest < ActiveSupport::TestCase
  # setup:全てのテストの前に実行される
  def setup
    @sc = SearchCondition.new(days_from_today: 0, days_count: 1, area_code: "130", genre_code: "0101", keyword: "甲子園")
  end

  test "バリデーション成功" do
    assert @sc.valid?
  end

  test "バリデーション成功：検索ワード空欄" do
    @sc.keyword = ""
    assert @sc.valid?
  end

  test "バリデーション成功：全ジャンル" do
    @sc.keyword = "all"
    assert @sc.valid?
  end

  test "バリデーション失敗：日付不正" do
    @sc.days_from_today = 8
    assert_not @sc.valid?
  end

  test "バリデーション失敗：放送エリア不正" do
    @sc.area_code = "999"
    assert_not @sc.valid?
  end

  test "バリデーション失敗：放送ジャンル不正" do
    @sc.area_code = "9999"
    assert_not @sc.valid?
  end

end