require "sinatra/base"
require "sinatra/flash"
require "./lib/user_management"
require "./lib/user"
require "./lib/space_manager"
require "./lib/database_connection"
require "./database_connection_setup.rb"
require "./lib/booking"
require "./lib/booking_management"

class Makersbnb < Sinatra::Base
  enable :sessions, :method_override
  register Sinatra::Flash
  whichdb

  get "/" do
    erb(:index)
  end

  post "/signup" do
    exists = UserManagement.user_exists?(params[:email])
    if exists == false 
      user = UserManagement.sign_up(User.new(params[:email], params[:name], params[:password]))
      session[:user] = user.user_id
      flash[:notice] = "Thank you for signing up - you are now logged in."
      redirect("/spaces")
    elsif exists == true 
        flash[:notice] = "User already exists"
        redirect("/")
    end
  end

  get "/sessions/new" do
    erb(:login)
  end

  post "/sessions" do
    user = UserManagement.login(params[:email], params[:password])
    if user == false 
      flash[:notice] = "Incorrect email or password"
      redirect('/sessions/new')
    else 
      session[:user] = user.user_id
      flash[:notice] = "You are logged in."
      redirect("/spaces")
    end 
  end

  get "/spaces/new" do
    erb :'spaces/new'
  end

  post "/spaces/new/add" do
    new_space = Space.new(params[:name], params[:price], params[:description], session[:user])
    SpaceManager.create(new_space)
    redirect "/spaces"
  end

  get "/spaces" do
    @spaces = SpaceManager.all
    erb :'/spaces/spaces'
  end

  get "/spaces/:userid" do
    @user_spaces = SpaceManager.user_spaces(session[:user])
    @pending_bookings = BookingManagement.pending_bookings(session[:user])
    erb :'spaces/user_spaces'
  end

  post "/space/:userid/approve" do
    BookingManagement.confirm_booking(params[:booking_id], true)
    redirect "/spaces/" + params[:userid]
  end

  post "/space/:userid/deny" do
    BookingManagement.confirm_booking(params[:booking_id], false)
    redirect "/spaces/" + params[:userid]
  end

  post "/sessions/destroy" do
    session.clear
    flash[:notice] = "You are logged out."
    redirect("/sessions/new")
  end

  get "/space/:spaceid" do
    session[:spaceid] = params[:spaceid]
    @viewed_space = SpaceManager.view_space(params[:spaceid])
    erb :'spaces/space'
  end

  get "/space/:spaceid/:months" do
    month = SpaceManager.month_conversion(params[:month])
    @available_dates = SpaceManager.availability(params[:spaceid], month)
    erb :'spaces/dates'
  end

  get "/spaces/:spaceid/book" do
    booking = Booking.new(session[:spaceid], session[:user], params[:booking_date])
    @requested_booking = BookingManagement.request(booking)
    erb :'spaces/requested_booking'
  end

  get "/bookings/:user" do
    @mybookings = BookingManagement.user_bookings(session[:user])
    erb :'spaces/mybookings'
  end

  run! if app_file == $0
end
