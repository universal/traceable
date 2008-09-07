class CreateTraceableTeaseds < ActiveRecord::Migration
  def self.up
    create_table :traceable_teaseds do |t|
      t.string :type
      t.references :traceable_request
      t.text :line
      t.integer :lineno
      t.timestamps
    end
  end

  def self.down
    drop_table :traceable_teaseds
  end
end
