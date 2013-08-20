class DraftController < ApplicationController
  before_filter :get_user

  def index
    @players = Player.all
    @drafts  = @user.drafts
  end
  
  def taken
    name = params[:name]
    status = params[:status]
    player = Player.find_by_name(name)
    DraftPlayer.create({:player=>player,:draft_id=>session[:draft_id],:status=>status})
    pstring = "<tr><td>#{player.name}</td><td>#{player.team}</td><td>#{player.fpts}</td><td>#{player.fvalue.round(2)}</td><td>#{player.adp}</td></tr>"
    render :json => {:text =>"success",:pstring=>pstring}
  end

  def clear_roster
    session[:draft_id]=nil
    redirect_to :action=>:index
  end
end
