class CreateMovieDates < ActiveRecord::Migration[8.1]
  def change
    create_table :movie_dates do |t|
      t.date :date
      t.index :date, unique: true
      t.timestamps
    end
  end
end
