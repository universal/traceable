class AuditableGenerator < Rails::Generator::NamedBase
  
  attr_reader   :session_name, :request_name, :change_name,
                :session_class_path, :request_class_path, :change_class_path,
                :session_file_path, :request_file_path, :change_file_path,
                :session_class_nesting, :request_class_nesting, :change_class_nesting,
                :session_class_nesting_depth, :request_class_nesting_depth, :change_class_nesting_depth,
                :session_class_name, :request_class_name, :change_class_name,
                :session_singular_name, :request_singular_name, :change_singular_name,
                :session_plural_name, :request_plural_name, :change_plural_name,
                :session_file_name, :request_file_name, :change_file_name
  alias_method  :session_table_name, :session_plural_name
  alias_method  :request_table_name, :request_plural_name
  alias_method  :change_table_name, :change_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    arg_session_name = args.shift || 'auditable_session'
    arg_request_name = args.shift || 'auditable_request'
    arg_change_name = args.shift || 'auditable_change'

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

    # changes model
    change_name, @change_class_path, @change_file_path, @change_class_nesting, @change_class_nesting_depth = extract_modules(arg_change_name)
    @change_class_name_without_nesting, @change_file_name, @change_plural_name = inflect_names(change_name)
    @change_singular_name = @change_file_name.singularize
    if @change_class_nesting.empty?
      @change_class_name = @change_class_name_without_nesting
    else
      @change_class_name = "#{@change_class_nesting}::#{@change_class_name_without_nesting}"
    end    
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}Helper"
      m.class_collisions session_class_path, "#{session_class_name}" 
      m.class_collisions request_class_path, "#{request_class_name}"  
      m.class_collisions change_class_path, "#{change_class_name}" 
      
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/models', session_class_path)
      m.directory File.join('app/models', request_class_path)
      m.directory File.join('app/models', change_class_path)

      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)

      m.template 'sessions.rb',
                  File.join('app/models',
                            session_class_path,
                            "#{session_file_name}.rb")
      m.template 'requests.rb',
                  File.join('app/models',
                            request_class_path,
                            "#{request_file_name}.rb")
      m.template 'changes.rb',
                  File.join('app/models',
                            change_class_path,
                            "#{change_file_name}.rb")

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}Tables",
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}_tables"
      end
    
      # m.directory "lib"
      # m.template 'README', "README"
    end
  end
end
