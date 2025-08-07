class ApplicationController < ActionController::Base

  private

  # 検索フォームをセットする
  def set_search_form
    # 検索条件のドロップダウン用のハッシュを作る
    @dates = SearchCondition.broadcast_dates
    @areas = SearchCondition.broadcast_areas
    @genres = SearchCondition.program_genres
    # デフォルトの選択肢、キーワードを設定する
    session[:date] = "week" unless session[:date]
    session[:area] = "130" unless session[:area]
    session[:genre] = "all" unless session[:genre]
  end
end
