module Traceable
  class BasicHandler
    require File.dirname(__FILE__) + '/line_types'
    
    attr_accessor :status, :results, :current, :stats, :teased
    
    Result = Struct.new(:start, :between, :end)
    Stats = Struct.new(:started, :failed, :completed, :teased, :unknown)
    def initialize
      @status = :ready
      @results = []
      @stats = Stats.new(0,0,0,0,0)
      @teased = []
    end
   
    def log_lines
      Traceable::LineTypes::LOG_LINES
    end

    def started(line, options)
      @status = :inside
      @current = Result.new(line,[])
      @stats[:started] += 1
    end

    def failed(line, options)
      if @status == :inside
        @status = :ready
        @current[:end] = line
        @results << @current if @current
        @stats[:failed] += 1    
      end
    end

    def completed(line, options)
      if @status == :inside
        @status = :ready
        @current[:end] = line
        @results << @current if @current
        @stats[:completed] += 1
      end
    end

    def teased_line(type, line, options)
      @stats[:teased] += 1
      @teased << line
    end 
    
    def unknown_line(line)
      @current[:between] << line if @status == :inside
      @stats[:unknown] += 1
    end      

 end
end
