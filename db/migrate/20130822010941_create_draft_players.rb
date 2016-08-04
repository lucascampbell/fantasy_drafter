class CreateDraftPlayers < ActiveRecord::Migration
  def change
    create_table :draft_players do |t|
      t.integer :draft_id
      t.integer :player_id
      t.string :status
      t.timestamps
    end
  end
end
