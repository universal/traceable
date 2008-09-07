class CreateTraceableUnknowns < ActiveRecord::Migration
  def self.up
    create_table :traceable_unknowns do |t|
      t.string :line
      t.references :traceable_request
      t.integer :lineno
      t.timestamps
    end
  end

  def self.down
    drop_table :traceable_unknowns
  end
end
