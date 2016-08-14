require 'csv'
require 'open-uri'
namespace :load_data do
  
  task :players, [:position] => :environment do |t,args|
    puts "args is #{args[:position]}"
    position = args[:position]
    path = File.join(Rails.root,"public/#{position}.csv")
    file = File.new(path)
    csv  = CSV.parse(file)

     #remove first three lines
    # if position == 'defense'
    #   2.times do
    #     csv.shift
    #   end
    # else
    5.times do
      csv.shift
    end
    #end
    
    case position
    when 'RB'
      base_line = (csv[35][18]).to_f
    when 'WR'
      base_line = (csv[37][18]).to_f
    when 'TE'
      base_line = (csv[10][18]).to_f
    when 'QB'
      base_line = (csv[11][18]).to_f
    when 'defense'
      base_line = (csv[10][15]).to_f
    end
    
    csv.each do |row|
      raw = row.first.split(",")
      if position == 'defense'
        name = raw[0].split("|")[0].strip
      else
        tmpData = raw[0].split(position.upcase)
        name    = tmpData[0].strip
        team    = tmpData[1].split("|")[1].strip
      end
      if position == 'defense'
        player = Player.find_by_name(name)
      else
        player = Player.find_by_name_and_team(name,team)
      end
      if player
        puts "player #{name} already in system update will occur"
        if position == 'defense'
          player.update_attributes({:position=>position,:team=>name,:fpts=>row[15],:fvalue =>(row[15].to_f - base_line)})
        else
          player.update_attributes({:position=>position,:team=>team,:fpts=>row[18],:fvalue =>(row[18].to_f - base_line)})
        end
      else
        if position == 'defense'
          player = Player.create!({:name=>name,:position=>position,:team=>player,:fpts=>row[15],:fvalue =>(row[15].to_f - base_line)})
        else
          player = Player.create!({:name=>name,:position=>position,:team=>team,:fpts=>row[18],:fvalue =>(row[18].to_f - base_line)})
        end
        puts "created new player #{name}"
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
