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
	@users = User.all
	@button_label = "Search!"
	@button_label2 = "Show User Lists"

	@movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
	@movies_top_ten.sort! { |a,b| a.rank <=> b.rank }

       	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false) 
	@movies.each do |mv|
                mv.destroy
		mv.save
        end

	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)

    respond_to do |format|
	format.html
        format.js {render :layout => false}
    end
	
  end

  def new_search
	@user = User.find(params[:user_id])	
	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)
		
	@movies.each do |mv|
		mv.destroy
	end

	@searchterm = Searchterm.create(searchterm_params)

	@searchterm.term = URI.escape(@searchterm.term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
	@searchterm.term = @searchterm.term.gsub(" ", "+")

	movie_name_json = RestClient.get("http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=2y2cb9atvjr4bp2s3kmyrkp9&q=#{@searchterm.term}&page_limit=15") 
	movie_result_hash = JSON.load(movie_name_json)

	movie_result_hash["movies"].map do |info|

		params[:title] = info["title"]
		params[:year] = info["year"]
		params[:mpaa_rating] = info["mpaa_rating"]
		params[:synopsis] = info["synopsis"]
		
		if info["abridged_cast"] == []
			if info["poster"] == []
				params[:poster] = "http://images.rottentomatoescdn.com/images/redesign/poster_default.gif"
				params[:link] = info["links"]["alternate"]	
				params[:abridged_cast] = "Not Listed"
				params[:top_ten] = false
				Movie.create(movie_params)
			else
				params[:poster] = info["posters"]["original"]
				params[:link] = info["links"]["alternate"]
                                params[:abridged_cast] = "Not Listed"
				params[:top_ten] = false
                                Movie.create(movie_params)
			end	
		else
			if info["poster"] == []
				params[:poster] = "http://images.rottentomatoescdn.com/images/redesign/poster_default.gif"
				params[:abridged_cast] = info["abridged_cast"][0]["name"]
				params[:link] = info["links"]["alternate"]
				params[:top_ten] = false
				Movie.create(movie_params)
			else
				params[:poster] = info["posters"]["original"]	
				params[:abridged_cast] = info["abridged_cast"][0]["name"]
				params[:link] = info["links"]["alternate"]
				params[:top_ten] = false
                                Movie.create(movie_params)
			end
		end
	end

        @movies = Movie.all.where(:user_id => @user.id).where(:user_id => @user.id).where(:top_ten => false)
	@movies.sort! { |a,b| a.created_at <=> b.created_at }
        @movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
        @movies_top_ten.sort! { |a,b| a.rank <=> b.rank }	

    respond_to do |format|
      	format.js {render :layout => false}
    end 
  end

  def update_movie
    if(params.has_key?(:move_up))
        @movie = Movie.find(params[:id])
	@user = User.find(@movie.user.id)
        @movieabove = (Movie.all.where(:user_id => @user.id).where(:top_ten => true).where(:rank => (@movie.rank - 1)))[0]

        @movieabove.rank = @movie.rank
        @movie.rank = @movie.rank - 1

        @movie.save
        @movieabove.save

        @movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
        @movies_top_ten.sort! { |a,b| a.rank <=> b.rank }
	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)
    elsif(params.has_key?(:move_down))
	@movie = Movie.find(params[:id])
	@user = User.find(@movie.user.id)
        @moviebelow = (Movie.all.where(:user_id => @user.id).where(:top_ten => true).where(:rank => (@movie.rank + 1)))[0]
 
        @moviebelow.rank = @movie.rank
        @movie.rank = @movie.rank + 1

        @movie.save
        @moviebelow.save

        @movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
        @movies_top_ten.sort! { |a,b| a.rank <=> b.rank }
   	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)
    else	
	@movie = Movie.find(params[:id])
	@movie.top_ten = true
	@user = User.find(params[:user_id])
	@movie.rank = Movie.all.where(:user_id => @user.id).where(:top_ten => true).length + 1
	@movie.save

	@movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
	@movies_top_ten.sort! { |a,b| a.rank <=> b.rank }
	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)
    end

    respond_to do |format|
        format.js {render :layout => false}
    end	
  end

  def delete_movie
	@movie = Movie.find(params[:id])
	@user = User.find(@movie.user.id)
	@movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
	@movies_top_ten.sort! { |a,b| a.rank <=> b.rank }

	unless(@movie.rank == @movies_top_ten.length)
		@moviebelow = (Movie.all.where(:user_id => @user.id).where(:top_ten => true).where(:rank => (@movie.rank + 1)))[0]

		@movies_top_ten_sub_array = @movies_top_ten[(@moviebelow.rank - 1)..(@movies_top_ten.length - 1)]

		@movies_top_ten_sub_array.each do |mv|
			mv.rank = mv.rank - 1
			mv.save
		end

	end

	
	@movie.destroy
	@movie.save

	@movies_top_ten = Movie.all.where(:user_id => @user.id).where(:top_ten => true)
	@movies_top_ten.sort! { |a,b| a.rank <=> b.rank }
	@movies = Movie.all.where(:top_ten => false)

    respond_to do |format|
        format.js {render :layout => false}
    end
  end

  def edit_essay
	
     if Movie.exists?(params[:movie_id])
	@movie = Movie.find(params[:movie_id])
	@user = User.find(@movie.user.id)
	@essay = Essay.find(params[:id])

	if(params.has_key?(:essay))
		@essay.update_attributes(params.require(:essay).permit(:title, :body))
		flash[:notice] = "Updated Essay!"
	else
		flash[:notice] = ""
	end

	@movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)
	@movies.each do |mv|
		mv.destroy
		mv.save
	end

        @movies_top_ten =  Movie.all.where(:user_id => @user.id).where(:top_ten => true)
        @movies_top_ten.sort! { |a,b| a.rank <=> b.rank }
     else
		flash[:notice] = "That movie has been deleted!"
	@user = User.find(params[:user_id])
	@movies_top_ten =  Movie.all.where(:user_id => @user.id).where(:top_ten => true)
        @movies_top_ten.sort! { |a,b| a.rank <=> b.rank }
     end

    respond_to do |format|
        format.js {render :layout => false}
    end    
  end
  
  def show_user_lists
  	@user = User.find(params[:id])
	@users = User.all 

        @movies = Movie.all.where(:user_id => @user.id).where(:top_ten => false)
	@movies.each do |mv|
                mv.destroy
                mv.save
        end
	
    respond_to do |format|
        format.js {render :layout => false}
    end 	
  end

  private
  def searchterm_params
    params.require(:searchterm).permit(:user_id, :term)
  end

  def movie_params
    params.permit(:user_id, :title, :year, :mpaa_rating, :abridged_cast, :synopsis, :poster, :top_ten, :link)
  end

  def essay_params
    params.permit!.except(:utf8, :_method, :user_id, :commit, :action, :controller, :essay)
  end
 
end
