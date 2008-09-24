require 'traceable'
require 'audit_log'
config.after_initialize do
  ::DEFAULT_AUDIT_LOG = AuditLog.new(File.join(RAILS_ROOT, "log", "#{config.environment}_audit.log"))
  ::DEFAULT_AUDIT_LOG.auto_flushing = false
  ::DEFAULT_AUDIT_LOG.set_non_blocking_io
  ::DEFAULT_AUDIT_LOG.info("\n")
  ::DEFAULT_AUDIT_LOG.flush
  require 'hooks/action_controller'
end
