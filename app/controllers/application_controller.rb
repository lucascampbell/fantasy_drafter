class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_user
    @user = User.find_by_league_id(params[:league_id])
    unless @user
      @user = User.new(:email => "", :password => params[:league_id], :password_confirmation => params[:league_id])
      @user.save
      sign_in @user, :bypass => true 
    end
  end
end
