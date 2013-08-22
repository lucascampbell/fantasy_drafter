class DraftPlayer < ActiveRecord::Base
	belongs_to :draft
	belongs_to :player
  validates :draft_id, uniqueness: {scope: :player_id}, presence: true
  validates :player_id, :presence=>true
end
