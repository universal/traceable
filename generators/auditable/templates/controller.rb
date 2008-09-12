class <%= class_name %>Controller < ApplicationController
  
  def parse
    Traceable::Parser.new("log/#{Rails.configuration.environment}_audit.log", Traceable::AuditHandler.new(<%= session_class_name %>, <%= request_class_name %>, <%= modification_class_name %>)).parse
    redirect_to audits_path
    # TODO js/ajaxified verison
  end 
  
  def search
    if params[:query] && params[:query] != ""
      @<%= session_plural_name %> = <%= session_class_name %>.search(params[:query])
    else
      @<%= session_plural_name %> = <%= session_class_name %>.find(:all) 
    end
    render :action => 'index'
  end
  
  # GET /<%= session_plural_name %>
  # GET /<%= session_plural_name %>.xml
  def index
    @<%= session_plural_name %> = <%= session_class_name %>.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= session_plural_name %>.to_xml(:except => [:updated_at, :created_at]) }
    end
  end

  # GET /<%= session_plural_name %>/1
  # GET /<%= session_plural_name %>/1.xml
  def show
    @<%= session_singular_name %> = <%= session_class_name %>.find(params[:id])
    if params[:query] && params[:query] != ""
    @<%= request_plural_name %> = <%= request_class_name %>.search(params[:query], :conditions => {:<%= session_singular_name %>_id => @<%= session_singular_name %>.id})
    else
      @<%= request_plural_name %> = @<%= session_singular_name %>.requests
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= session_singular_name %>.to_xml(:include => :requests, :except => [:updated_at, :created_at]) }
    end
  end
end
