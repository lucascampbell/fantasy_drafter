class DraftController < ApplicationController
  before_filter :get_user, :only=> :index

  def index
    begin
      if params[:draft]
        session[:draft_id] = params[:draft]
        @curr_draft = current_user.drafts.find_by_id(params[:draft])
      else
        @curr_draft = current_user.drafts.first
        session[:draft_id] = @curr_draft.id
      end
      @players    = @curr_draft.players.count > 0 ? Player.where("id not in (?)",@curr_draft.players.collect(&:id)) : Player.all
    rescue Exception => e
      reset_session
    end
  end

  def taken
    id     = params[:id]
    status = params[:status]
    player = Player.find(id)
    DraftPlayer.create!({:player_id=>player.id,:draft_id=>session[:draft_id],:status=>status})
    pstring = "<tr><td>#{player.name}</td><td>#{player.team}</td><td>#{player.fpts}</td><td>#{player.fvalue.round(2)}</td><td>#{player.adp}</td></tr>"
    render :json => {:text =>"success",:pstring=>pstring}
  end

  def clear_roster
    league_id    = session[:league_id]
    access_token = session[:access_token]
    reset_session
    session[:league_id]    = league_id
    session[:access_token] = access_token
    redirect_to :action=>:index
  end

end
