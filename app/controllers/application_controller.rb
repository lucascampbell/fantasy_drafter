class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_user
    league_id        = params[:league_id] || "testuser"
    access_token     = params[:access_token] || "testtoken"
    @user            = User.find_by_league_id(league_id)
    unless @user
      @user = User.new(:email => "lucas.campbellrossen@gmail.com", :password => league_id, :password_confirmation => league_id,:league_id=>league_id,:access_token=>access_token)
      @user.save!
      sign_in @user, :bypass => true 
    else
      @user.update_attribute("access_token",access_token)
    end
    session[:draft_id] = Draft.find(params[:draft]) if params[:draft]
    session[:draft_id] = Draft.create!({:name=>"#{Draft.count + 1}_#{Time.now.to_i}",:user_id=>@user.id}).id if session[:draft_id].nil?
  end
end
