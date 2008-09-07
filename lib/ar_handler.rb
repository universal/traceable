module Traceable
  class ArHandler
    require File.dirname(__FILE__) + '/line_types'
    
    attr_accessor :status, :current, :stats, :teased, :unknown
    
    Stats = Struct.new(:started, :failed, :completed, :teased, :unknown)
    
    #allowed types, to remove unneccessary calls to handler
    # include? or method call + if faster? ;)
    
    def initialize
      @status = :ready
      @stats = Stats.new(0,0,0,0,0)
      @teased = []
      @unknown = []
    end
    
    def log_lines
      Traceable::LineTypes::LOG_LINES
    end
   
    def prepare
    end 
    
    def finish_up
      requests = TraceableRequest.find(:all, :conditions => {:controller => "SessionsController", :action => "create", :method => "POST"})
      requests.each do |request|
        if request.traceable_session
          if match = request.parameters.match(/"login"=>("\w+")/)
            request.traceable_session.login = match[1]
            request.traceable_session.save
          end
        end
      end
    end    
#   { :controller => 1, :action => 2, :ip => 3, :method => 5, :timestamp => 4 }
    def started(line, options, match_data)
      unless TraceableRequest.first(:conditions => {:controller => match_data[1],
                                                    :action => match_data[2],
                                                    :ip => match_data[3],
                                                    :method => match_data[5],
                                                    :when => match_data[4]})
        @status = :inside
        @current = TraceableRequest.new(:controller => match_data[1], 
                                        :action => match_data[2],
                                        :ip => match_data[3],
                                        :method => match_data[5],
                                        :when => match_data[4])
        @stats[:started] += 1
      end
    end

#   {:session_id => 1}
    def session(line, options, match_data)
      if @status == :inside
        @current.traceable_session = TraceableSession.find_or_create_by_session_id(match_data[1])
      # else session line outside of a request log block "found"  
      end
    end
    
    def parameters(line, options, match_data)
      if @status == :inside
        @current.parameters = match_data[1]
      end
    end
  
    def render(line, options, match_data)
      if @status == :inside
        @current.rendered = match_data[options[:params][:view]]
      end
    end
    
    def redirect(line, options, match_data)
      if @status == :inside
        @current.redirected = match_data[1]
      end    
    end
    
    def failed(line, options, match_data)
      if @status == :inside
        @status = :ready
        @current.save
# TODO ..
        @stats[:failed] += 1    
      end
    end

#   { :url => 7, :status => [6, :to_i], :duration => [1, :to_f], :rendering => [3, :to_f], :db => [5, :to_f] }
    def completed(line, options, match_data)
      if @status == :inside
        @status = :ready
        @current.duration = match_data[1].to_f
        @current.url = match_data[7]
        @current.http_status = match_data[6].to_i
        @current.save
        @stats[:completed] += 1
      end
    end
    
    def teased_line(type, line, options, lineno)
      @stats[:teased] += 1
      if @status == :inside
        @current.teaseds.build(:type => type.to_s, :line => line, :lineno => lineno)
      else
        TraceableTeased.create(:type => type.to_s, :line => line, :lineno => lineno)        
      end
    end 
    
    def unknown_line(line, lineno)
      return if line == "\n"
      if @status == :inside
        @current.unknowns.build(:line => line, :lineno => lineno)
      else
        TraceableUnknown.create(:line => line, :lineno => lineno)
      end    
    end      

 end
end
