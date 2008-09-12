class ActionController::Base
  around_filter do |controller, action|
    DEFAULT_AUDIT_LOG.audit controller
    action.call
    DEFAULT_AUDIT_LOG.end_audit
  end
 
  ## def audit_log; DEF.. ||= new AuditLog....
  
end
