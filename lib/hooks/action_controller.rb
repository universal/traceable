class ActionController::Base
  around_filter do |controller, action|
    audit_id(controller.session)
    DEFAULT_AUDIT_LOG.audit controller
    action.call
    DEFAULT_AUDIT_LOG.end_audit
  end
  
  private 
  def self.audit_id(session)
    session[:audit_id] ||= generate_id
  end
  
  AUDIT_CHARS = 'abcdefghjkmnpqrstuvwxyz-_%§$&/(}{)ABCDEFGHJKLMNOPQRSTUVWXYZ23456789'  
  def self.generate_id(length=32)  
    audit_id = ''  
    length.times { |i| audit_id << AUDIT_CHARS[rand(AUDIT_CHARS.length)] }  
    audit_id  
  end  
 
  ## def audit_log; DEF.. ||= new AuditLog....
  
end
