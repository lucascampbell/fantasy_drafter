class Draft < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :players
  
  validates :user_id, :presence => true
  validates :name, :presence => true
end
