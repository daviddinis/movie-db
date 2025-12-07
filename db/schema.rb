# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_07_155728) do
  create_table "movie_dates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_movie_dates_on_date", unique: true
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "movie_date_id", null: false
    t.float "popularity", null: false
    t.string "poster_path"
    t.float "rating"
    t.string "title"
    t.bigint "tmdb_id", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_date_id"], name: "index_movies_on_movie_date_id"
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end
end
