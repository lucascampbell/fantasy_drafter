class Player < ActiveRecord::Base
  validates :name, uniqueness: {scope: :team}, presence: true
  has_many :draft_players
  has_many :drafts, :through=> :draft_players
end
