require 'net/http'
require 'uri'

class ProgramsController < ApplicationController
  API_KEY = Rails.application.credentials.dig(:nhk_api_key) # シークレットからAPIキーを取得

  def index
    sc = SearchCondition.new #検索条件

    if params[:date] == "week"
      sc.days_from_today = 0 # 検索開始日（今日から0日後）
      sc.days_count = 8      # 検索日数
    else
      sc.days_from_today = params[:date].to_i
      sc.days_count = 1
    end

    # パラメータの値を検索条件オブジェクト、およびセッションに記憶する
    session[:date]    = params[:date]
    session[:area]    = sc.area_code  = params[:area]
    session[:genre]   = sc.genre_code = params[:genre]
    session[:keyword] = sc.keyword    = params[:keyword]

    if sc.valid?
      @programs_by_day = {} # 日毎の番組リスト

      #検索日数ぶん処理を繰り返す
      sc.days_count.times do
        uri = create_uri(sc)
        uri.query = URI.encode_www_form(key: API_KEY) # クエリパラメータにAPIキーを設定

        # リクエストを送り、レスポンスを受け取る
        res = Net::HTTP.get_response(uri)
        # レスポンスが成功でなければ
        unless res.is_a?(Net::HTTPSuccess)
          flash[:warning] = "リクエストエラーが発生しました"
          redirect_to root_path and return
        end
        # 受け取った情報（json）をハッシュに変換
        body = JSON.parse(res.body)

        programs_by_channel = {} # チャンネル毎の番組リスト
        channels = {"g1" => "ＮＨＫ総合", "e1" => "ＮＨＫＥテレ", "s1" => "ＮＨＫＢＳ"}
        channels.each do |ch_code, ch_name|
          programs = body.dig('list', ch_code) || []

          # 検索ワードが空欄でない場合
          if sc.keyword != ""
            # 検索ワードがtitle、subtitle、contentのいずれかと部分一致する番組を抽出
            programs.select! do |p|
              p['title'].include?(sc.keyword) || p['subtitle'].include?(sc.keyword) || p['content'].include?(sc.keyword)
            end
          end

          programs.each do |p|
            # 番組の開始・終了時刻を読みやすく加工する
            p['start_time'] = shap_iso(p['start_time'])
            p['end_time'] = shap_iso(p['end_time'])
          end

          # チャンネル毎の番組リストに、抽出した番組リストを追加する
          programs_by_channel[ch_name] = programs if programs != []
        end

        d = Date.today + sc.days_from_today
        japanese_weekdays = %w[日 月 火 水 木 金 土]
        # 日毎の番組リストに、チャンネル毎の番組リストを追加する
        @programs_by_day[d.strftime("%Y年%m月%d日（#{japanese_weekdays[d.wday]}）")] = programs_by_channel

        # 日付を+1日する
        sc.days_from_today += 1
      end

    else
      # 不正な検索条件の場合、ホームページにリダイレクト
      flash[:warning] = "不正な検索条件です"
      redirect_to root_path and return
    end

  end

  private

  def nhk_api_key
    @nhk_api_key ||= Rails.application.credentials.dig(:nhk_api_key)
  end

  # NHK番組表API用のURIを生成するメソッド
  def create_uri(sc)
    # 検索対象日を設定
    target_date = (Date.today + sc.days_from_today).strftime('%Y-%m-%d')
    if sc.genre_code == "all"
      # ProgramListAPI用（ジャンル指定なし）のURIを生成
      URI("https://api.nhk.or.jp/v2/pg/list/#{sc.area_code}/tv/#{target_date}.json")
    else
      # ProgramGenreAPI用（ジャンル指定あり）のURIを生成
      URI("https://api.nhk.or.jp/v2/pg/genre/#{sc.area_code}/tv/#{sc.genre_code}/#{target_date}.json")
    end
  end

  # ISO 8601形式の時刻（文字列）を読みやすく加工するメソッド
  def shap_iso(iso_datetime)
    # パースしてDateTimeオブジェクトを作成
    dt = DateTime.parse(iso_datetime)

    # 午前/午後の判定と12時間表記への変換
    hour = dt.hour
    period = hour < 12 ? '午前' : '午後'
    hour12 = hour % 12

    # 時/分の表記をスペースで調整
    hour12 = hour12 < 10 ? " #{hour12.to_s}" : hour12
    min = dt.min < 10 ? " #{dt.min.to_s}" : dt.min

    # フォーマットして出力（開始or終了日時で分岐）
    "#{period}#{hour12}時#{min}分"
  end
end
