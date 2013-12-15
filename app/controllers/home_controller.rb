require 'json'
require 'rest-client'

class HomeController < ApplicationController
  before_filter :authenticate_user!, except: [:landing]
  def landing
	if !@auth.nil?
		redirect_to(home_index_path)
	end
  end
 
  def index
	@user = current_user
	@button_label = "Search!"

	@movies = Movie.all.where(:user_id => @user.id)

        @movies.each do |mv|
                mv.destroy
		mv.save
        end

	@movies = Movie.all.where(:user_id => @user.id)

    respond_to do |format|
	format.html
        format.js {render :layout => false}
    end
	
  end

  def new_search
	@user = User.find(params[:user_id])	
	@movies = Movie.all.where(:user_id => @user.id)
		
	@movies.each do |mv|
		mv.destroy
	end

	@searchterm = Searchterm.create(searchterm_params)
	@searchterm.term = @searchterm.term.gsub(" ", "+")
	@searchterm.term = URI.escape(@searchterm.term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))


	movie_name_json = RestClient.get("http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=2y2cb9atvjr4bp2s3kmyrkp9&q=#{@searchterm.term}&page_limit=5") 
	movie_result_hash = JSON.load(movie_name_json)

	movie_result_hash["movies"].map do |info|

		params[:title] = info["title"]
		params[:year] = info["year"]
		params[:mpaa_rating] = info["mpaa_rating"]
		params[:synopsis] = info["synopsis"]
		
		if info["abridged_cast"] == []
			if info["poster"] == []
				params[:poster] = "http://images.rottentomatoescdn.com/images/redesign/poster_default.gif"	
				params[:abridged_cast] = "Not Listed"
				Movie.create(movie_params)
			else
				params[:poster] = info["posters"]["original"]
                                params[:abridged_cast] = "Not Listed"
                                Movie.create(movie_params)
			end	
		else
			if info["poster"] == []
				params[:poster] = "http://images.rottentomatoescdn.com/images/redesign/poster_default.gif"
				params[:abridged_cast] = info["abridged_cast"][0]["name"]
				Movie.create(movie_params)
			else
				params[:poster] = info["posters"]["original"]	
				params[:abridged_cast] = info["abridged_cast"][0]["name"]
                                Movie.create(movie_params)
			end
		end
	end

    @movies = Movie.all.where(:user_id => @user.id)	

    respond_to do |format|
      	format.js {render :layout => false}
    end 
  end

  private
  def searchterm_params
    params.require(:searchterm).permit(:user_id, :term)
  end

  def movie_params
    params.permit(:user_id, :title, :year, :mpaa_rating, :abridged_cast, :synopsis, :poster)
  end
 
end
