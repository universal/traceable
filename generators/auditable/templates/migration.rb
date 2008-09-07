class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= session_table_name %>" do |t|
      t.string :session_id
      t.string :login
      t.timestamps
    end

    create_table "<%= request_table_name %>" do |t|
      t.datetime :when
      t.string :ip
      t.string :method
      t.string :controller
      t.string :action
      t.references "<%= session_singular_name %>"
      t.text :parameters
      t.timestamps
    end
    add_index("<%= request_table_name %>", [:controller, :action, :method, :ip, :when], :name => "<%= singular_name %>_find_index")
    
    create_table "<%= change_table_name %>" do |t|
       t.string :audited_type
       t.references :audited
       t.text :changes
       t.text :attributez
       t.string :status
       t.references "<%= request_singular_name %>"       
    end    
        
  end

  def self.down
    drop_table "<%= session_table_name %>"
    drop_table "<%= request_table_name %>"
    drop_table "<%= change_table_name %>"
  end
end
