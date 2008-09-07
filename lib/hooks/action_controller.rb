class ActionController::Base
  before_filter {|controller| audit(controller)}
  after_filter :end_audit
 
  private
  def self.audit(controller)
    DEFAULT_AUDIT_LOG.audit controller
  end
  
  def end_audit
    DEFAULT_AUDIT_LOG.end_audit
  end
  
end
