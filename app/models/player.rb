class Player < ActiveRecord::Base
  validates :name, uniqueness: {scope: :team}, presence: true

  has_and_belongs_to_many :drafts
end
