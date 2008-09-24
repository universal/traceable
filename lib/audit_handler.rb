module Traceable
  class AuditHandler
    require File.dirname(__FILE__) + '/line_types'
    
    attr_accessor :status, :current_request, :current_change
    
    attr_reader :session, :request, :change, :stats
  
    Stats = Struct.new(:started, :before_saved, :after_saved, :finished, :teased, :unknown)
 
    def initialize(session, request, change)
      @status = :outside
      @session = session
      @request = request
      @change = change
      @stats = Stats.new(0,0,0,0,0,0)
    end
    
    def log_lines
      Traceable::LineTypes::AUDIT_LINES
    end
   
    def prepare
    end 
    
    def finish_up
    end    
    
    # :params => {:when => 1, :ip => 2, :method => 3, :controller => 4, :action => 5, :audit_id => 6, :params => 7 }
    def started(line, options, match_data)
      unless request.first(:conditions => {:controller => match_data[options[:params][:controller]],
                                           :action => match_data[options[:params][:action]],
                                           :ip => match_data[options[:params][:ip]],
                                           :method => match_data[options[:params][:method]],
                                           :when => match_data[options[:params][:when]].to_s(:db)})
        @status = :inside
        @current_request = request.new(:controller => match_data[options[:params][:controller]],
                               :action => match_data[options[:params][:action]],
                               :ip => match_data[options[:params][:ip]],
                               :method => match_data[options[:params][:method]],
                               :when => match_data[options[:params][:when]],
                               :parameters => match_data[options[:params][:when]].to_s(:db))

        unless sess = session.find_by_audit_id(match_data[options[:params][:audit_id]])
          sess = session.new(:audit_id => match_data[options[:params][:audit_id]])
        end
        login = match_data[options[:params][:login]]
        sess.login = login unless login == "not_logged_in"
        sess.save
        @current_request.session = session
        @current_request.save
        @stats[:started] += 1
      end
    end
    # :params => {:model => 1, :id => 2, :changes => 3}
    def before_saved(line, options, match_data)
      @current_change = change.new(:modifications => match_data[options[:params][:changes]])
      @stats[:before_saved] += 1
    end
    # :params => {:status => 1, :model => 2, :id => 3, :attributes => 4}
    def after_saved(line, options, match_data)
      @current_change.status = match_data[options[:params][:status]]
      @current_change.audited_type = match_data[options[:params][:model]]
      @current_change.audited_id = match_data[options[:params][:id]]
      @current_change.values = match_data[options[:params][:attributes]]
      if @status == :inside
        @current_request.modifications << @current_change
      else
        @current_change.save
      end
      @stats[:after_saved] += 1
    end       
       
    def finished(line, options, match_data)
     @status = nil
     @stats[:finished] += 1
    end
    
    def teased_line(type, line, options, lineno)
      @stats[:teased] += 1
    end 
    
    def unknown_line(line, lineno)
      @stats[:unknown] += 1
    end  
  end
end
