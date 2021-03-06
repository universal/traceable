class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= session_table_name %> do |t|
      t.string :audit_id
      t.string :login
      t.integer :<%= request_table_name %>_count, :default => 0, :null => false
      t.timestamps
    end

    create_table :<%= request_table_name %> do |t|
      t.datetime :when
      t.string :ip
      t.string :method
      t.string :controller
      t.string :action
      t.references :<%= session_singular_name %>
      t.text :parameters
      t.integer :<%= modification_table_name %>_count, :default => 0, :null => false
      t.timestamps
    end
    add_index("<%= request_table_name %>", [:controller, :action, :method, :ip, :when], :name => "<%= singular_name %>_find_index")
    
    create_table :<%= modification_table_name %> do |t|
       t.string :audited_type
       t.references :audited
       t.text :modifications
       t.text :values
       t.string :status
       t.references :<%= request_singular_name %>
    end    
        
  end

  def self.down
    drop_table :<%= session_table_name %>
    drop_table :<%= request_table_name %>
    drop_table :<%= modification_table_name %>
  end
end
