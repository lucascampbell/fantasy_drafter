class DraftPlayer < ActiveRecord::Base
	belongs_to :draft
	belongs_to :player
end
