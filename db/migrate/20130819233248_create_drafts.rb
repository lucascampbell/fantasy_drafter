class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.string :name
      t.string :scoring
      t.integer :teams
      t.integer :user_id
      t.timestamps
    end
  end
end
