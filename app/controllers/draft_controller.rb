class DraftController < ApplicationController

  def index
    @players = Player.all
  end
  
  def taken
    name = params[:name]
    status = "taken"#params[:status]
    player = Player.find_by_name(name)
    player.update_attribute('status',status)
    render :json => {:text =>"success"}
  end
end
