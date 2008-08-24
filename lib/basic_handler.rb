module Traceable
  class BasicHandler
    require File.dirname(__FILE__) + '/line_types'
    
    attr_accessor :status, :results, :current, :stats, :teased, :unknown, :session
    
#    Result = Struct.new(:start, :between, :end)
    Seat = Struct.new(:session_id, :requests, :start,:last,:user )
    Request = Struct.new(:controller, :action, :ip, :method, :when, :duration, :parameters, :unknown)
    Stats = Struct.new(:started, :failed, :completed, :teased, :unknown)
    def initialize
      @status = :ready
      @results = []
      @stats = Stats.new(0,0,0,0,0)
      @teased = []
      @unknown = []
    end
   
    def log_lines
      Traceable::LineTypes::LOG_LINES
    end

#   { :controller => 1, :action => 2, :ip => 3, :method => 5, :timestamp => 4 }
    def started(line, options, match_data)
      @status = :inside
      @current = Request.new(match_data[1], match_data[2], match_data[3], match_data[5], match_data[4])
      @stats[:started] += 1
    end

    def failed(line, options, match_data)
      if @status == :inside
        @status = :ready
# TODO ..
        @stats[:failed] += 1    
      end
    end

#   { :url => 7, :status => [6, :to_i], :duration => [1, :to_f], :rendering => [3, :to_f], :db => [5, :to_f] }
    def completed(line, options, match_data)
      if @status == :inside
        @status = :ready
        @current[:duration] = match_data[1]
# TODO ...
        @stats[:completed] += 1
      end
    end

#   {:session_id => 1}
    def session(line, options, match_data)
      if @status == :inside
        session_id = match_data[1]
        if (@session && (@session.session_id == session_id)) || (@session = results.find{|session| session.session_id == session_id})
          @session[:last] = @current.when
        else
          @session = Seat.new(session_id, [], @current.when, @current.when)
          @results << @session  
        end
        @session[:requests] = (@session[:requests] || [])  << @current
      # else session line outside of a request log block "found"  
      end
    end
    
    def parameters(line, options, match_data)
      if @status == :inside
        @current[:parameters] = match_data[1]
      end
    end
    
    
    def teased_line(type, line, options)
      puts type
      @stats[:teased] += 1
      @teased << line
    end 
    
    def unknown_line(line)
      return if line == "\n"
      if @status == :inside
        @current[:unknown] = (@current[:unknown] || []) << line
      end
      @unknown << line
#      @current[:between] << line if @status == :inside
      @stats[:unknown] += 1
    end      

 end
end
