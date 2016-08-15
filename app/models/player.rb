class Player < ActiveRecord::Base
  validates :name, uniqueness: {scope: :team}, presence: true
  has_many :draft_players
  has_many :drafts, :through=> :draft_players

  POSITION_LIST = ['wr','rb','qb','te']

  def self.load_adp
    url_adp = "https://www.fantasypros.com/nfl/rankings/ppr-cheatsheets.php"
    page = Nokogiri::HTML(RestClient.get(url_adp))
    outer_div  = page.xpath("//div[contains(@class,'mobile-table')]").first
    table_body = outer_div.xpath(".//tbody").first
    player_trs = table_body.xpath(".//tr[contains(@class,'mpb-available')]")

    #puts "found row #{player_trs}"
    player_trs.each do |row|
      stat_td  = row.xpath(".//td")
      puts "td is #{stat_td}"
      raw_name = stat_td[1].text.split(" ")
      puts "raw name is #{raw_name}"
      name     = raw_name[0..1].join(" ").strip
      team     = raw_name[2].strip if raw_name[2]

      player = Player.where(name:name).where(team:team).take
      if player
        puts "player #{player.name} already in system update will occur"
        player.update_attributes({adp:stat_td[8].text.to_f})
      else
        logger.debug ("cant find player #{name}")
      end
    end

  end

  def self.load_fp_data
    POSITION_LIST.each do |position|
      puts "looping #{position}"

      url_proj = "https://www.fantasypros.com/nfl/projections/#{position}.php?scoring=PPR"
      page = Nokogiri::HTML(RestClient.get(url_proj))
      outer_div  = page.xpath("//div[contains(@class,'mobile-table')]").first
      table_body = outer_div.xpath(".//tbody").first
      player_trs = table_body.xpath(".//tr")


      case position
      when 'rb'
        base_line_player = player_trs[35].xpath(".//td")
        fpt_index        = 8
      when 'wr'
        base_line_player = player_trs[37].xpath(".//td")
        fpt_index        = 8
      when 'te'
        base_line_player = player_trs[10].xpath(".//td")
        fpt_index        = 5
      when 'qb'
        base_line_player = player_trs[11].xpath(".//td")
        fpt_index        = 10
      end


      player_trs.each do |row|
        stat_td  = row.xpath(".//td")
        raw_name = stat_td[0].text.split(" ")
        puts "raw name is #{raw_name}"
        name     = raw_name[0..1].join(" ").strip
        team     = raw_name[2].strip if raw_name[2]
        puts "process #{name} on team #{team}"
        player = Player.where(name:name).where(team:team).take
        if player
          puts "player #{player.name} already in system update will occur"
          player.update_attributes!({:position=>position,:team=>team,:fpts=>stat_td[fpt_index].text.to_f,:fvalue =>(stat_td[fpt_index].text.to_f - base_line_player[fpt_index].text.to_f)})
        else
          puts "creating #{name} for first time"
          Player.create!({:name=>name,:position=>position,:team=>team,:fpts=>stat_td[fpt_index].text.to_f,:fvalue =>(stat_td[fpt_index].text.to_f - base_line_player[fpt_index].text.to_f)})
        end
      end
    end


  end
  # def self.load_data
  #   all_player_url = "http://api.cbssports.com/fantasy/players/rankings?version=3.0&access_token=#{User.first.access_token}&response_format=JSON"

  #   fantasy_points_url = "http://api.cbssports.com/fantasy/league/fantasy-points?version=3.0&response_format=JSON&period=projections&timeframe=2014&access_token=#{User.first.access_token}"

  #   adp_url              = "http://api.cbssports.com/fantasy/players/average-draft-position?version=3.0&access_token=#{User.first.access_token}&response_format=JSON"

  #   resp                 = RestClient.get all_player_url
  #   r                    = JSON.parse(resp.body)
  #   player_rankings_hash = r["body"]["rankings"]["positions"]

  #   resp2                = RestClient.get fantasy_points_url
  #   r2                   = JSON.parse(resp2.body)
  #   fantasy_pt_hash      = r2["body"]["fantasy_points"]

  #   resp3                = RestClient.get adp_url
  #   r3                   = JSON.parse(resp3.body)
  #   adp_hash             = r3["body"]["average_draft_position"]["players"]


  #   player_rankings_hash.each do |position|
  #   	puts "position is #{position}"
  #     next if position['abbr'] == "K"
  #     case position["abbr"]
  #     when 'RB'
  #       id = position["players"][35]["id"]
  #       base_line = fantasy_pt_hash[id]
  #     when 'WR'
  #       id = position["players"][37]["id"]
  #       base_line = fantasy_pt_hash[id]
  #     when 'TE'
  #       id = position["players"][10]["id"]
  #       base_line = fantasy_pt_hash[id]
  #     when 'QB'
  #       id = position["players"][11]["id"]
  #       base_line = fantasy_pt_hash[id]
  #     when 'DST'
  #       id = position["players"][10]["id"]
  #       base_line = fantasy_pt_hash[id]
  #     end

  #     position["players"].each do |player|
  #       p       = Player.find_by_uid(player["id"])
  #       adp_raw = adp_hash.select{|plyr|plyr["id"] == player["id"]}
  #       adp     = adp_raw.first["avg"] unless adp_raw.empty?

  #       if p
  #         puts "player #{player['fullname']} already in system update will occur"
  #         p.update_attributes({:position=>position["abbr"],:team=>player["pro_team"],:fpts=>fantasy_pt_hash[player["id"]],:adp=>adp,:fvalue =>(fantasy_pt_hash[player["id"]].to_f - base_line.to_f)})
  #       else
  #         puts "creating #{player['fullname']} for first time"
  #         p = Player.create!({:uid=>player['id'],:name=>player['fullname'],:position=>position['abbr'],:team=>player["pro_team"],:adp=>adp,:fpts=>fantasy_pt_hash[player["id"]],:fvalue =>(fantasy_pt_hash[player["id"]].to_f - base_line.to_f)})
  #       end
  #     end
  #   end
  # end
end
