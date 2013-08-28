class Player < ActiveRecord::Base
  validates :name, uniqueness: {scope: :team}, presence: true
  has_many :draft_players
  has_many :drafts, :through=> :draft_players

  def self.load_data
    all_player_url = "http://api.cbssports.com/fantasy/players/rankings?version=2.0&access_token=#{User.first.access_token}&response_format=JSON"

    fantasy_points_url = "http://api.cbssports.com/fantasy/league/fantasy-points?version=2.0&response_format=JSON&period=projections&timeframe=2013&access_token=#{User.first.access_token}"

    adp_url              = "http://api.cbssports.com/fantasy/players/average-draft-position?version=2.0&access_token=#{User.first.access_token}&response_format=JSON"

    resp                 = RestClient.get all_player_url
    r                    = JSON.parse(resp.body)
    player_rankings_hash = r["body"]["rankings"]["positions"]

    resp2                = RestClient.get fantasy_points_url
    r2                   = JSON.parse(resp2.body)
    fantasy_pt_hash      = r2["body"]["fantasy_points"]

    resp3                = RestClient.get adp_url
    r3                   = JSON.parse(resp3.body)
    adp_hash             = r3["body"]["average_draft_position"]["players"]


    player_rankings_hash.each do |position|
    	puts "position is #{position}"
      next if position['abbr'] == "K"
      case position["abbr"]
      when 'RB'
        id = position["players"][35]["id"]
        base_line = fantasy_pt_hash[id]
      when 'WR'
        id = position["players"][37]["id"]
        base_line = fantasy_pt_hash[id]
      when 'TE'
        id = position["players"][10]["id"]
        base_line = fantasy_pt_hash[id]
      when 'QB'
        id = position["players"][11]["id"]
        base_line = fantasy_pt_hash[id]
      when 'DST'
        id = position["players"][10]["id"]
        base_line = fantasy_pt_hash[id]
      end

      position["players"].each do |player|
        p       = Player.find_by_uid(player["id"])
        adp_raw = adp_hash.select{|plyr|plyr["id"] == player["id"]}
        adp     = adp_raw.first["avg"] unless adp_raw.empty?
 
        if p
          puts "player #{player['fullname']} already in system update will occur"
          player.update_attributes({:position=>position["abbr"],:team=>player["pro_team"],:fpts=>fantasy_pt_hash[player["id"]],:adp=>adp,:fvalue =>(fantasy_pt_hash[player["id"]].to_f - base_line.to_f)})
        else
          puts "creating #{player['fullname']} for first time"
          p = Player.create!({:uid=>player['id'],:name=>player['fullname'],:position=>position['abbr'],:team=>player["pro_team"],:adp=>adp,:fpts=>fantasy_pt_hash[player["id"]],:fvalue =>(fantasy_pt_hash[player["id"]].to_f - base_line.to_f)})
        end
      end
    end
  end
end
