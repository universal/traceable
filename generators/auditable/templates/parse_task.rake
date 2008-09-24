namespace :<%= plural_name %> do
  desc "Parses the current environments audit log file"
  task :parse  => :environment do
    Traceable::Parser.new("log/#{Rails.configuration.environment}_audit.log", Traceable::AuditHandler.new(<%= session_class_name %>, <%= request_class_name%>, <%= modification_class_name %>)).parse
  end
end
