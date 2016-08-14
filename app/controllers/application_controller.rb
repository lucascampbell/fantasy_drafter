class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_user
    #redirect_to(new_user_session_path) and return unless user_signed_in?#params[:league_id] or session[:league_id] or 
    user  = User.first
    unless user_signed_in?
      sign_in(:user,user) 
    end
    #session[:draft_id] = Draft.find(params[:draft]).id if params[:draft]
    puts "current user is #{current_user}"
    current_user = user
    session[:draft_id] = Draft.create!({:name=>"#{Draft.count + 1}_#{Time.now.to_i}",:user_id=>user.id}).id
  end
end
