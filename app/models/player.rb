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
    player_trs = table_body.xpath(".//tr[contains(@class,'mpb-player')]")

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
  
end
