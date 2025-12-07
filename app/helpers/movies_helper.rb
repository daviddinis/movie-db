module MoviesHelper
  require 'net/http'

  def search_movie(date_start, date_end, page = 1)
    url = URI("https://api.themoviedb.org/3/discover/movie?primary_release_date.gte=#{date_start.strftime('%Y-%m-%d')}&primary_release_date.lte=#{date_end.strftime('%Y-%m-%d')}&page=#{page}&sort_by=release_date.asc")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["accept"] = "application/json"

    request["Authorization"] = "bearer #{Rails.application.credentials.config[:tmdb_token]}"
    response = JSON.parse(https.request(request).read_body)
    movies = parse_response(response)

    {
      total_results: response["total_results"],
      movies: movies.map { |movie| save_movie(movie) }
    }
  end

  def parse_response(response)
    response["results"].map do |movie|
      {
        tmdb_id: movie["id"],
        title: movie["title"],
        release_date: Date.parse(movie["release_date"]),
        description: movie["overview"],
        rating: movie["vote_average"].round(1),
        popularity: movie["popularity"],
        poster_path: "https://image.tmdb.org/t/p/w500#{movie["poster_path"]}"
      }
    end
  end

  def save_movie(movie)
    date = MovieDate.find_by(date: movie[:release_date]) || MovieDate.create(date: movie[:release_date])
    Movie.find_by(tmdb_id: movie[:tmdb_id]) || Movie.create(movie.to_hash.except(:release_date).merge(movie_date_id: date.id))
  end

  def movie_to_hash(movie)
    {
      id: movie.tmdb_id,
      title: movie.title,
      description: movie.description,
      release_date: movie.movie_date.date,
      poster_path: movie.poster_path,
      rating: movie.rating
    }
  end
end
