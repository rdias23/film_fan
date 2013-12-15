class AddTopTenToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :top_ten, :boolean
  end
end
