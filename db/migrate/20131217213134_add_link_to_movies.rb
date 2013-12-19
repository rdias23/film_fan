class AddLinkToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :link, :string
  end
end
