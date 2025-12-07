class AddMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.float :rating
      t.bigint :movie_date_id, null: false
      t.text :description
      t.string :poster_path
      t.bigint :tmdb_id, null: false
      t.float :popularity, null: false
      t.index :tmdb_id, unique: true
      t.index :movie_date_id
      t.timestamps
    end
  end
end
