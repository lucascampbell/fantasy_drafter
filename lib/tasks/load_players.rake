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
    if position == 'defense'
      2.times do
        csv.shift
      end
    else
      3.times do
        csv.shift
      end
    end

    case position
    when 'rb'
      base_line = (csv[36][20]).to_f
    when 'wr'
      base_line = (csv[37][20]).to_f
    when 'te'
      base_line = (csv[10][20]).to_f
    when 'qb'
      base_line = (csv[11][20]).to_f
    when 'defense'
      base_line = (csv[10][15]).to_f
    end
    
    csv.each do |row| 
      raw = row.first.split(" ")
      if position == 'defense'
        name = raw[0]
      else
        name = "#{raw[1]} #{raw[0].gsub(',','')}"
      end
      if position == 'defense'
        player = Player.find_by_name(raw[0])
      else
        player = Player.find_by_name_and_team(name,raw[3])
      end
      if player
        puts "player #{name} already in system update will occur"
        if position == 'defense'
          player.update_attributes({:position=>position,:team=>raw[2],:fpts=>row[15],:fvalue =>(row[15].to_f - base_line)})
        else
          player.update_attributes({:position=>position,:team=>raw[3],:fpts=>row[20],:fvalue =>(row[20].to_f - base_line)})
        end
      else
        if position == 'defense'
          player = Player.create!({:name=>name,:position=>position,:team=>raw[2],:fpts=>row[15],:fvalue =>(row[15].to_f - base_line)})
        else
          player = Player.create!({:name=>name,:position=>position,:team=>raw[3],:fpts=>row[20],:fvalue =>(row[20].to_f - base_line)})
        end
        puts "created new player #{name}"
      end
    end
  end

  task :adp => :environment do 
    si   = open("https://fantasyfootballcalculator.com/adp_xml.php?format=ppr&teams=10")           
    csv  = CSV.parse(si.read)

    5.times do
      csv.shift
    end
    
    csv.each do |row|
      player = Player.find_by_name_and_team(row[2],row[4])
      if player
        player.update_attributes({:adp=>row[0]})
        puts "updating player #{player.name}"
      else
        puts "player #{row} not found."
      end
    end
  end
  
end