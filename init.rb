require 'traceable'
require 'audit_log'
require 'auditor'
config.after_initialize do
  ::DEFAULT_AUDIT_LOG = AuditLog.new(File.join(RAILS_ROOT, "log", "#{config.environment}_audit.log"))
  ::DEFAULT_AUDIT_LOG.auto_flushing = false
  ::DEFAULT_AUDIT_LOG.set_non_blocking_io
  require 'hooks/action_controller'
end
