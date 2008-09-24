module Traceable
  module LineTypes
    ## rails log analyzer
    ## http://github.com/wvanbergen/rails-log-analyzer/tree/master
    LOG_LINES = {
      :started => {
        :teaser => /^Processing/,
        :regexp => /^Processing (\w+)#(\w+) \(for (\d+\.\d+\.\d+\.\d+) at (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)\) \[([A-Z]+)\]/,
        :params => { :controller => 1, :action => 2, :ip => 3, :method => 5, :timestamp => 4 }
      },
      :failed => {
        :teaser => /Error/,
        :regexp => /(RuntimeError|ActiveRecord::\w+|ArgumentError|ActionController::\w+|ActionView::\w+|NoMethodError|NameError) \((\w+)\): (\w+)/,
        :params => { :error => 1, :exception_string => 2, :stack_trace => 3 }
      },
      :completed => {
        :teaser => /^Completed/,
        :regexp => /^Completed in (\d+\.\d{5}) \(\d+ reqs\/sec\) (\| Rendering: (\d+\.\d{5}) \(\d+\%\) )?(\| DB: (\d+\.\d{5}) \(\d+\%\) )?\| (\d\d\d).+\[(http.+)\]/,
        :params => { :url => 7, :status => 6, :duration => 1, :rendering => 3, :db => 5}
      },
      :session => {
        :teaser => /Session ID/, 
        :regexp => /Session ID: (\w+)/,
        :params => {:id => 1}
      },
      :parameters => {
        :teaser => /^\s\sParameters/,
        :regexp => /^\s\sParameters: \{(.*)\}$/,
        :params => {:params => 1}
      },
      :render => {
        :teaser => /^(Rendering \w|Sending data)/,
        :regexp => /^(Rendering|Sending data) ([\w\/\.]+)/,
        :params => {:view => 2}
      },
      :redirect => {
       :teaser => /^Redirected/,
       :regexp => /^Redirected to (http.+)/,
       :params => {:url => 1}
      }
    }
    AUDIT_LINES = {
#       WHEN: IP: METHOD: CONTROLLER: ACTION: AUDIT-ID: LOGIN: PARAMS: 
      :started => {
        :teaser => /^REQUEST WHEN/,
        :regexp => /^REQUEST WHEN: (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d) IP: (\d+.\d+\.\d+\.\d+) METHOD: (\w+) CONTROLLER: (\w+) ACTION: (\w+) AUDIT-ID: (.+) LOGIN: (\w+) PARAMS: (.+)/,
        :params => {:when => 1, :ip => 2, :method => 3, :controller => 4, :action => 5, :audit_id => 6, :login => 7, :params => 8 }
      },
#      MODEL: #{model.class} ID: #{model.new_record? ? "new_record" : model.id} CHANGES: #{model.changes.inspect}}
      :before_saved => {
        :teaser => /^MODEL/,
        :regexp => /^MODEL: (\w+) ID: (\d+|new_record) CHANGES: (.+)/,
        :params => {:model => 1, :id => 2, :changes => 3}

      },
#      #{status}: #{model.class} ID: #{model.id} ATTRIBUTES: #{model.attributes.inspect}})
      :after_saved => {
       :teaser => /CREATED|UPDATED|DESTROYED/,
       :regexp => /^(CREATED|UPDATED|DESTROYED): (\w+) ID: (\d+) ATTRIBUTES: (.+)/,
       :params => {:status => 1, :model => 2, :id => 3, :attributes => 4}
      },
      :finished => {
        :teaser => /^REQUEST ENDED/,
        :regexp => /^REQUEST ENDED/,
        :params => { }
      }
    }
  end
end
