module DraftHelper

  def full_postion_name(position)
    case position
    when 'QB'
      "Quarterbacks"
    when 'RB'
      "Running Backs"
    when 'WR'
      "Wide Receivers"
    when 'TE'
      "Tight Ends"
    when 'D'
      "Defenses"
    when 'myteam'
      "Draft #{Draft.first.name}"
    end
  end
end
