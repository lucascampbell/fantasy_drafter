class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :status
      t.string :position
      t.string :team
      t.integer :fpts
      t.decimal :adp
      t.decimal :fvalue
      t.timestamps
    end
  end
end
