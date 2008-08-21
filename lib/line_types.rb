module Traceable
  module LineTypes
    ## rails log analyzer
    ## http://github.com/wvanbergen/rails-log-analyzer/tree/master
  LOG_LINES = {
      :started => {
        :teaser => /Processing/,
        :regexp => /Processing (\w+)#(\w+) \(for (\d+\.\d+\.\d+\.\d+) at (\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)\) \[([A-Z]+)\]/,
        :params => { :controller => 1, :action => 2, :ip => 3, :method => 5, :timestamp => 4 }
      },
      :failed => {
        :teaser => /Error/,
        :regexp => /(RuntimeError|ActiveRecord::\w+|ArgumentError) \((\w+)\): (\w+)/,
        :params => { :error => 1, :exception_string => 2, :stack_trace => 3 }
      },
      :completed => {
        :teaser => /Completed/,
        :regexp => /Completed in (\d+\.\d{5}) \(\d+ reqs\/sec\) (\| Rendering: (\d+\.\d{5}) \(\d+\%\) )?(\| DB: (\d+\.\d{5}) \(\d+\%\) )?\| (\d\d\d).+\[(http.+)\]/,
        :params => { :url => 7, :status => [6, :to_i], :duration => [1, :to_f], :rendering => [3, :to_f], :db => [5, :to_f] }
      }
    }
  end
end
