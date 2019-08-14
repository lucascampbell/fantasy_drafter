require 'csv'
class Player < ActiveRecord::Base
  validates :name, uniqueness: {scope: :team}, presence: true
  has_many :draft_players
  has_many :drafts, :through=> :draft_players

  POSITION_LIST = ['wr','rb','qb','te','def']

  KEEPER_LIST = {
                  wr:['JuJu Smith-Schuster'],
                  rb:['Derrius Guice','Kerryon Johnson'],
                  te:['George Kittle'],
                  def:[],
                  qb:['Patrick Mahomes']
                }

  RB_BASELINE = 47
  WR_BASELINE = 58
  QB_BASELINE = 17
  TE_BASELINE = 14

  def self.load_fg
    POSITION_LIST.each do |position|
      path = File.join(Rails.root,"public/fg/#{position}.csv")
      data = CSV.read(path)
      data.shift
      data = data.delete_if{|row| KEEPER_LIST[position.to_sym].include? row[0] }
      case position
      when 'rb'
        base_line_player = data[RB_BASELINE]
      when 'wr'
        base_line_player = data[WR_BASELINE]
      when 'te'
        base_line_player = data[TE_BASELINE]
      when 'qb'
        base_line_player = data[QB_BASELINE]
      when 'def'
        base_line_player = data[10]
      end

      data.each do |row|
        fpts_column = row.size - 1
        #player = Player.find_or_create_by(uid: row["id"])
        player = Player.where(name:row[0]).where(team:row[1]).first_or_create do |player|
          player.name = row[0],
          player.team = row[1]
        end
        hsh = {
                position: position,
                name:row[0],
                team:row[1],
                fpts:row[fpts_column].to_i,
                fvalue: (row[fpts_column].to_f - base_line_player[fpts_column].to_f).to_i
              }
        player.update_attributes(hsh)

      end
    end
  end

  def self.load_adp
    url_adp = "https://www.fantasypros.com/nfl/rankings/ppr-cheatsheets.php"
    page = Nokogiri::HTML(RestClient.get(url_adp))
    outer_div  = page.xpath("//div[contains(@class,'mobile-table')]").first
    table_body = outer_div.xpath(".//tbody").first
    player_trs = table_body.xpath(".//tr[contains(@class,'mpb-player')]")

    #puts "found row #{player_trs}"
    player_trs.each do |row|
      stat_td  = row.xpath(".//td")
      name     = stat_td[1].children[0]['data-name']
      team     = stat_td[1].children[0]['data-team']

      player = Player.where(name:name).where(team:team).take
      if player
        puts "stat_td is #{stat_td}"
        puts "player #{player.name} already in system update will occur"
        player.update_attributes({adp:stat_td[9].text.to_f})
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
