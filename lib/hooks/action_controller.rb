class ActionController::Base
  around_filter :audit

  def audit
    audit_id(self.session)
    DEFAULT_AUDIT_LOG.audit(self, self.current_user)
    yield
    DEFAULT_AUDIT_LOG.end_audit
  end
  
  private 
  def audit_id(session)
    session[:audit_id] ||= generate_id
  end
  
  AUDIT_CHARS = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ1234567890'  
  def self.generate_id(length=32)  
    audit_id = ''  
    length.times { |i| audit_id << AUDIT_CHARS[rand(AUDIT_CHARS.length)] }  
    audit_id  
  end  
 
  ## def audit_log; DEF.. ||= new AuditLog....
  
end
