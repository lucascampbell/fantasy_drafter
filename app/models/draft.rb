class Draft < ActiveRecord::Base
  belongs_to :user
  has_many :draft_players
  has_many :players, :through => :draft_players
  
  validates :user_id, :presence => true
  validates :name, :presence => true
end
