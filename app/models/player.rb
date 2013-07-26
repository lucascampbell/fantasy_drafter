class Player < ActiveRecord::Base
  validates :name, uniqueness: {scope: :team}, presence: true
end
