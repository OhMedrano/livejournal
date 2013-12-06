require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'sinatra/activerecord'

require 'rack-flash'
require 'bcrypt'

configure(:development){ set :database, 'sqlite3:///twitter.sqlite3' }

require './models'

#stuff you need for the flash
enable :sessions
use Rack::Flash, :sweep => true
set :sessions => true


helpers do
  def current_user
    if session[:user_id].nil?
      nil
    else
      User.find(session[:user_id])
    end
  end
end


def current_user
  if session[:user_id].nil?
    nil
  else
    User.find(session[:user_id])
  end
end


get '/' do
  @posts = Post.last(20)
  haml :home
end

#signup process - signup form
get '/users/new' do 
  haml :'users/new'
end

#signup process - process signup form data
post '/users/new' do
  @user = User.new(params[:user])
  if @user.save
    flash[:notice] = "You've signed up successfully."
    redirect '/'
  else
    flash[:alert] = "There was a problem signing you up."
    redirect '/users/new'
  end
end

#sign in process - sign in form
get '/sign_in' do
  haml :signin
end

#sign in process - process sign in form data
post '/sign_in' do
  @user = User.authenticate(params[:user][:email], params[:user][:password])
  if @user
    session[:user_id] = @user.id
    flash[:notice] = "You've been signed in successfully, #{@user.fname}."
  else
    flash[:alert] = "There was a problem signing you in."
  end
  redirect '/'
end

#sign out route destroys the user's session by setting the session hash value for user_id to nil
get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You've been signed out successfully."
  redirect '/'
end

#new posts route - form
get '/users/:id/posts/new' do
  @user = User.find(params[:id])
  if current_user == @user
    haml :new_post
  else
    redirect '/'
  end
end

#new posts route - process form data, authenticate user, create new post
post '/users/:id/posts/new' do
  @user = User.find(params[:id])
  if @user == current_user
    @post = Post.new(params[:post])
    if @post.save && @user.posts << @post
      flash[:notice] = "Your post was saved successfully."
      redirect "/users/#{@user.id}"
    else
      flash[:alert] = "There was a problem saving your post."
      redirect "/users/#{@user.id}/posts/new"
    end
  else
    redirect '/'
  end
end


#user profile route
get '/users/:id' do
  @user = User.find(params[:id])
  haml :'users/show'
end


#show post page
get '/users/:user_id/posts/:id' do
  @post = Post.find(params[:id])
  if @post.user_id == params[:user_id].to_i
    haml :'posts/show'
  else
    flash[:alert] = "Your post could not be found."
    redirect '/'
  end
end






