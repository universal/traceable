require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")
class AuditableGenerator < Rails::Generator::NamedBase
  
  attr_reader   :session_name, :request_name, :modification_name,
                :session_class_path, :request_class_path, :modification_class_path,
                :session_file_path, :request_file_path, :modification_file_path,
                :session_class_nesting, :request_class_nesting, :modification_class_nesting,
                :session_class_nesting_depth, :request_class_nesting_depth, :modification_class_nesting_depth,
                :session_class_name, :request_class_name, :modification_class_name,
                :session_singular_name, :request_singular_name, :modification_singular_name,
                :session_plural_name, :request_plural_name, :modification_plural_name,
                :session_file_name, :request_file_name, :modification_file_name
  alias_method  :session_table_name, :session_plural_name
  alias_method  :request_table_name, :request_plural_name
  alias_method  :modification_table_name, :modification_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    arg_session_name = args.shift || 'auditable_session'
    arg_request_name = args.shift || 'auditable_request'
    arg_modification_name = args.shift || 'auditable_modification'

    # sessions model
    session_name, @session_class_path, @session_file_path, @session_class_nesting, @session_class_nesting_depth = extract_modules(arg_session_name)
    @session_class_name_without_nesting, @session_file_name, @session_plural_name = inflect_names(session_name)
    @session_singular_name = @session_file_name.singularize
    if @session_class_nesting.empty?
      @session_class_name = @session_class_name_without_nesting
    else
      @session_class_name = "#{@session_class_nesting}::#{@session_class_name_without_nesting}"
    end    

    # requests model
    request_name, @request_class_path, @request_file_path, @request_class_nesting, @request_class_nesting_depth = extract_modules(arg_request_name)
    @request_class_name_without_nesting, @request_file_name, @request_plural_name = inflect_names(request_name)
    @request_singular_name = @request_file_name.singularize
    if @request_class_nesting.empty?
      @request_class_name = @request_class_name_without_nesting
    else
      @request_class_name = "#{@request_class_nesting}::#{@request_class_name_without_nesting}"
    end    

    # modifications model
    modification_name, @modification_class_path, @modification_file_path, @modification_class_nesting, @modification_class_nesting_depth = extract_modules(arg_modification_name)
    @modification_class_name_without_nesting, @modification_file_name, @modification_plural_name = inflect_names(modification_name)
    @modification_singular_name = @modification_file_name.singularize
    if @modification_class_nesting.empty?
      @modification_class_name = @modification_class_name_without_nesting
    else
      @modification_class_name = "#{@modification_class_nesting}::#{@modification_class_name_without_nesting}"
    end    
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}Helper"
      m.class_collisions session_class_path, "#{session_class_name}" 
      m.class_collisions request_class_path, "#{request_class_name}"  
      m.class_collisions modification_class_path, "#{modification_class_name}"
      m.class_collisions [], "Auditor" 
      
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/models', session_class_path)
      m.directory File.join('app/models', request_class_path)
      m.directory File.join('app/models', modification_class_path)

      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)
      
      m.template 'auditor.rb', File.join('lib', 'auditor.rb')
      
      m.template 'controller.rb',
                  File.join('app/controllers',
                            class_path,
                            "#{file_name}_controller.rb")

      m.template 'views/index.html.erb',  File.join('app/views', class_path, file_name, "index.html.erb")
      m.template 'views/show.html.erb',  File.join('app/views', class_path, file_name, "show.html.erb")
      m.template 'views/_modification.html.erb',  File.join('app/views', class_path, file_name, "_modification.html.erb")
      m.template 'views/_request.html.erb',  File.join('app/views', class_path, file_name, "_request.html.erb")

                            
      unless options[:skip_routes]
        # Note that this fails for nested classes -- you're on your own with setting up the routes.
        m.route_name(singular_name, "#{plural_name}/:id", {:controller => plural_name, :action => 'show'})
        m.route_name("parse_#{plural_name}",    "#{plural_name}/parse", {:controller => plural_name, :action => 'parse'})
        m.route_name(plural_name, "/#{plural_name}",   {:controller => plural_name, :action => 'index'})
      end

      m.template 'sessions.rb',
                  File.join('app/models',
                            session_class_path,
                            "#{session_file_name}.rb")
      m.template 'requests.rb',
                  File.join('app/models',
                            request_class_path,
                            "#{request_file_name}.rb")
      m.template 'modifications.rb',
                  File.join('app/models',
                            modification_class_path,
                            "#{modification_file_name}.rb")

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}Tables",
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}_tables"
      end
      
      # TODO post install notes...    

    end
  end
end
