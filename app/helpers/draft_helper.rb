module DraftHelper

  def full_postion_name(position)
    case position
    when 'qb'
      "Quarterbacks"
    when 'rb'
      "Running Backs"
    when 'wr'
      "Wide Receivers"
    when 'te'
      "Tight Ends"
    when 'defense'
      "Defenses"
    when 'myteam'
      "My Team"
    end
  end
end
