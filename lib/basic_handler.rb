module Traceable
  class BasicHandler
    require File.dirname(__FILE__) + '/line_types'
    
    attr_accessor :status
    
    def initialize
      @status = :ready
    end
   
    def log_lines
      Traceable::LineTypes::LOG_LINES
    end

    def started(line, options)
      puts line
    end

    def failed(line, options)
    end

    def completed(line, options)
    end

    def teased_line(type, line, options)
    end 
    
    def unknown_line(line)
    end      

 end
end
