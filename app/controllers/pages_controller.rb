class PagesController < ApplicationController
  def home
    @title = "アート・絵画・美術館・展覧会の感想まとめサイト | doodo"
    @description = "アート・展覧会の感想まとめサイト「doodo」のトップページです。doodoはアート・絵画・美術館・展覧会・美術展の感想が見れる検索サイトです。六本木、国立新美術館、上野、国立西洋美術館など、各地で開催されている展覧会の最新情報をご案内。"
    @exhb_logs = ExhbLog.order(id: "DESC").page(params[:page]).per(20)
    @exhibitions = Exhibition.is_open.order("star DESC NULLS LAST").page(params[:page]).per(20)
    @arts = Art.order("star DESC NULLS LAST").page(params[:page]).per(20)

    case params[:type]
    when 'exhb_logs', 'exhibitions', 'arts'
      render "#{params[:type]}"
    end
  end

  def trend
    @exhibitions = Exhibition.is_open.order("star DESC NULLS LAST").first(12)
    @arts = Art.order("star DESC NULLS LAST").first(12)
  end

  def search
    @title = "検索ページ | アート・展覧会の感想を見るなら【doodo】"
    @description = "アート・展覧会の感想まとめサイト「doodo」の検索ページです。doodoはアート・絵画・美術館・展覧会・美術展の感想が見れる検索サイトです。六本木、国立新美術館、上野、国立西洋美術館など、各地で開催されている展覧会の最新情報をご案内。"

    if params[:museum_area].present? || params[:museum_name].present?
      @museums = Museum
                     .where.not(id: 1)
                     .where("address LIKE ?", "%#{params[:museum_area]}%")
                     .where("name LIKE ?", "%#{params[:museum_name]}%")
                     .page(params[:page]).per(20)
    else
      @museums = Museum
                     .where.not(id: 1)
                     .includes(:exhibitions)
                     .order("exhibitions.star DESC NULLS LAST")
                     .page(params[:page]).per(20)
    end

    if params[:any].present?
      @exhibitions = Exhibition.where.not(id: 1).search_by_any(params).compact.sort do |a,b|
        if !a.star.present?
          1
        elsif !b.star.present?
          -1
        else
          b <=> a
        end
      end
    elsif params[:exhb_area].present? || params[:exhb_name].present? || params[:exhb_date].present?
      @exhibitions = Exhibition.where.not(id: 1).search_by(params).compact.sort do |a,b|
        if a.blank?
          1
        elsif b.blank?
          -1
        else
          if a.star.blank?
            1
          elsif b.star.blank?
            -1
          else
            b <=> a
          end
        end
      end
    else
      @exhibitions = Exhibition.where.not(id: 1).order("star DESC NULLS LAST").page(params[:page]).per(20)
    end

    if params[:art_name].present? || params[:artist_name].present?
      @arts = Art.search_by(params).compact.sort do |a,b|
        if !a.star.present?
          1
        elsif !b.star.present?
          -1
        else
          b <=> a
        end
      end
    else
      @arts = Art.order("star DESC NULLS LAST").page(params[:page]).per(20)
    end

    case params[:type]
    when 'search_museums', 'search_exhibitions', 'search_arts'
      render "#{params[:type]}"
    end
  end

  def post
    @title = "投稿ページ｜アート・展覧会の感想を見るなら【doodo】"
    @description = "アート・展覧会の感想まとめサイト「doodo」の投稿ページです。ログインすることで、アート・絵画・美術館・展覧会・美術展の感想を投稿することができます。六本木、国立新美術館、上野、国立西洋美術館など、各地で開催されている展覧会の最新情報もご案内。"
  end
end