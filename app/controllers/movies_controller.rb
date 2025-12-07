# Class
class MoviesController < ApplicationController
  include MoviesHelper
  PAGE_SIZE = 20
  
  def index
    render file: Rails.root.join("public", "build", "index.html"), layout: false
  end

  def search
    if params[:date_start].blank? || params[:date_end].blank?
      all_movies = Movie.all.order(popularity: :desc)
      return render json: { movies: all_movies.offset((params[:page].to_i - 1) * PAGE_SIZE).limit(PAGE_SIZE).map { |m| movie_to_hash(m) }, total_results: all_movies.count }
    end
    full_range = (Date.parse(params[:date_start])..Date.parse(params[:date_end])).to_a

    result = search_movie(full_range.first, full_range.last, params[:page]) if params[:total_results].nil?
    total_results = params[:total_results].nil? ? result[:total_results] : params[:total_results].to_i

    existing_movies = MovieDate.where(date: full_range)
    existing_dates = existing_movies.pluck(:date)
    missing_dates  = full_range - existing_dates

    current_page = Movie.joins(:movie_date).where(movie_dates: { date: existing_dates.first..existing_dates.last }).order(movie_dates: { date: :asc }).offset((params[:page].to_i - 1) * PAGE_SIZE).limit(PAGE_SIZE)

    puts current_page.count
    puts missing_dates.count
    puts existing_dates
    puts full_range
    return render json: { movies: current_page.map { |m| movie_to_hash(m) }, total_results: total_results } if current_page.count == PAGE_SIZE || missing_dates.empty?

    fetched_movies = if missing_dates.any? || !params[:total_pages].nil?
      search_movie(full_range.first, full_range.last, params[:page])
    else
    result
    end

    render json: { movies: fetched_movies[:movies].map { |m| movie_to_hash(m) }, total_results: total_results }
  end
end
