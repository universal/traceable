class CreateTraceableSessions < ActiveRecord::Migration
  def self.up
    create_table :traceable_sessions do |t|
      t.string :session_id
      t.references :user
      t.string :login
      t.timestamps
    end
  end

  def self.down
    drop_table :traceable_sessions
  end
end
