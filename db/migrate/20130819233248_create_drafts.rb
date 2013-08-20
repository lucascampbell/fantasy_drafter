class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.string :name
      t.string :scoring
      t.integer :teams
      t.timestamps
    end

    create_table :drafts_players do |t|
      t.belongs_to :draft
      t.belongs_to :player
    end
  end
end
