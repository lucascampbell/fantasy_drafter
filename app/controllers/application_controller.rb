class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # def after_sign_in_path_for(resource)
  #   if resource.is_a?(User)
  #     index_path
  #   else
  #     super
  #   end
  # end

  def get_user
    #session[:league_id] = nil
    #reset_session
    redirect_to(new_user_session_path) and return unless params[:league_id] or session[:league_id] or user_signed_in?
    unless user_signed_in?
      session[:league_id]     = params[:league_id] unless session[:league_id]
      session[:access_token]  = params[:access_token] unless session[:access_token]
      user                   = User.find_by_league_id(session[:league_id])
      unless user
        user = User.new(:email => "#{session[:league_id]}@gmail.com", :password => session[:league_id], :password_confirmation => session[:league_id],:league_id=>session[:league_id],:access_token=>session[:access_token])
        user.save!
      else
        user.update_attribute("access_token",session[:access_token])
      end
      sign_in(:user,user) 
    end
    session[:draft_id] = Draft.find(params[:draft]).id if params[:draft]
    session[:draft_id] = Draft.create!({:name=>"#{Draft.count + 1}_#{Time.now.to_i}",:user_id=>user.id}).id if session[:draft_id].nil?
  end
end
