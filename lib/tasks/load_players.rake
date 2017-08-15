require 'csv'
require 'open-uri'
namespace :load_data do
  task :cbs_players => :environment do |t, args|
    positions = ['RB','WR','QB','TE','K']
    path = File.join(Rails.root,"public/projections.csv")
    file = File.open(path)
    csv  = CSV.parse(file)
    csv.shift(3)
    csv.pop

    positions.each do |position|
      data = csv.select{|row|row[1].match(/#{position}/)}
      puts "position is #{position}"
      puts "data count is #{data.count}"
      case position
      when 'RB'
        base_line = (data[35][19]).to_f
      when 'WR'
        base_line = (data[37][19]).to_f
      when 'TE'
        base_line = (data[10][19]).to_f
      when 'QB'
        base_line = (data[11][19]).to_f
      when 'DST'
        base_line = (data[10][19]).to_f
      when 'K'
        base_line = (data[10][19]).to_f
      end

      data.each do |row|
        break if row[19].to_f < 1.0
        tmp_data = row[1].split("|")
        team = tmp_data[1].strip
        tmp_data2 = tmp_data[0].split(" ")
        position = tmp_data2.pop.strip
        name = tmp_data2.join(" ").gsub("'","")


        puts "player is #{name}"
        player = Player.where(name: name).where(team: team).take
        puts "player not found***********" unless player
        if player
          player.update_attributes({:position=>position,:fpts=>row[19].to_f,:fvalue =>(row[19].to_f - base_line)})
        else
          player = Player.create!({uid:'cbs',adp:0,:name=>name,:position=>position,:team=>team,:fpts=>row[19].to_f,:fvalue =>(row[19].to_f - base_line)})
        end
      end
    end
  end
  task :fff_players => :environment do |t,args|
    positions = ['RB','WR','QB','TE','DST','K']
    path = File.join(Rails.root,"public/fff.csv")
    file = File.open(path)
    csv  = CSV.parse(file)
    csv.shift
    positions.each do |position|
      puts "running for position #{position}"
      data = csv.select{|row|row[3] == position}
      case position
      when 'RB'
        base_line = (data[35][7]).to_f
      when 'WR'
        base_line = (data[37][7]).to_f
      when 'TE'
        base_line = (data[10][7]).to_f
      when 'QB'
        base_line = (data[11][7]).to_f
      when 'DST'
        base_line = (data[10][7]).to_f
      when 'K'
        base_line = (data[10][7]).to_f
      end

      data.each do |row|
        player = Player.where(uid: row[0]).take
        if player
          player.update_attributes({:position=>position,adp:row[28].to_f,:team=>row[2],:fpts=>row[7].to_f,:fvalue =>(row[7].to_f - base_line)})
        else
          player = Player.create!({uid:row[0],adp:row[28].to_f,:name=>row[1],:position=>position,:team=>row[2],:fpts=>row[7].to_f,:fvalue =>(row[7].to_f - base_line)})
        end
      end
    end
  end

  task :adp => :environment do
    si   = open("https://fantasyfootballcalculator.com/adp_csv.php?format=ppr&teams=10")
    csv  = CSV.parse(si.read)

    5.times do
      csv.shift
    end

    csv.each do |row|
      if row[2]
        name = row[2].gsub("Defense","DST").gsub(".","")
        player = Player.find_by_name_and_team(name,row[4])
        if player
          player.update_attributes({:adp=>row[0]})
          puts "updating player #{player.name}"
        else
          puts "player #{row} not found."
        end
      end
    end
  end

end
