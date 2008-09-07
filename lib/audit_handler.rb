module Traceable
  class AuditHandler
    require File.dirname(__FILE__) + '/line_types'
    
    attr_accessor :status, :current_request, :current_change
    
    attr_reader :session, :request, :change
    
    def initialize(session, request, change)
      @status = :outside
      @session = session
      @request = request
      @change = change
    end
    
    def log_lines
      Traceable::LineTypes::AUDIT_LINES
    end
   
    def prepare
    end 
    
    def finish_up
    end    
    
    # :params => {:when => 1, :ip => 2, :method => 3, :controller => 4, :action => 5, :session_id => 6, :params => 7 }
    def started(line, options, match_data)
      unless request.first(:conditions => {:controller => match_data[options[:params][:controller]],
                                           :action => match_data[options[:params][:action]],
                                           :ip => match_data[options[:params][:ip]],
                                           :method => match_data[options[:params][:method]],
                                           :when => match_data[options[:params][:when]]})
        @status = :inside
        @current_request = request.create(:controller => match_data[options[:params][:controller]],
                               :action => match_data[options[:params][:action]],
                               :ip => match_data[options[:params][:ip]],
                               :method => match_data[options[:params][:method]],
                               :when => match_data[options[:params][:when]],
                               :session => session.find_or_create_by_sessiond_id(match_data[options[:params][:session_id]]),
                               :parameters => match_data[options[:params][:params]])
      end
    end
    # :params => {:model => 1, :id => 2, :changes => 3}
    def before_saved(line, options, match_data)
      @current_change = change.new(:changes => match_data[options[:params][:changes]])
    end
    # :params => {:status => 1, :model => 2, :id => 3, :attributes => 4}
    def after_saved(line, options, match_data)
      @current_change.status = match_data[options[:params][:status]]
      @current_change.audited_type = match_data[options[:params][:model]]
      @current_change.audited_id = match_data[options[:params][:id]]
      @current_change.attributez = match_data[options[:params][:attributes]]
      if @status == :inside
        @current_request.changes << @current_change
      else
        @current_change.save
      end
    end          
    def finished(line, options, match_data)
     @status = nil
    end
    
    def teased_line(type, line, options, lineno)
    end 
    
    def unknown_line(line, lineno)
    end  
  end
end
