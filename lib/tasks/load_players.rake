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
    3.times do
      csv.shift
    end

    case position
    when 'rb'
      base_line = (csv[36][20]).to_f
    when 'wr'
      base_line = (csv[25][20]).to_f
    when 'te'
      base_line = (csv[10][20]).to_f
    when 'qb'
      base_line = (csv[11][20]).to_f
    when 'defense'
      base_line = (csv[10][20]).to_f
    end
    
    csv.each do |row| 
      raw = row.first.split(" ")
      name = "#{raw[1]} #{raw[0].gsub(',','')}"
      player = Player.find_by_name_and_team(name,row[2])
      if player
        puts "player #{name} already in system update will occur"
        player.update_attributes({:position=>position,:team=>raw[3],:fpts=>row[20],:fvalue =>(row[20].to_f - base_line)})
      else
        player = Player.create!({:name=>name,:position=>position,:team=>raw[3],:fpts=>row[20],:fvalue =>(row[20].to_f - base_line)})
        puts "created new player #{name}"
      end
    end
  end

  task :adp => :environment do 
    si   = open("http://fantasyfootballcalculator.com/adp_csv_ppr.php?teams=10")
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