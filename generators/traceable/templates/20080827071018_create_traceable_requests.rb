class CreateTraceableRequests < ActiveRecord::Migration
  def self.up
    create_table :traceable_requests do |t|
      t.string :controller
      t.string :action
      t.string :method
      t.string :ip
      t.datetime :when
      t.float :duration
      t.text :parameters
      t.integer :http_status
      t.string :url
      t.string :rendered
      t.string :redirected
      t.references :traceable_session
      t.timestamps
    end
    add_index(:traceable_requests, [:controller, :action, :method, :ip, :when], :name => "find_index")
  end

  def self.down
    drop_table :traceable_requests
  end
end
