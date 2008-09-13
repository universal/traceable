class AuditLog < ActiveSupport::BufferedLogger
  def audit(controller)
    flush
    info(%Q{REQUEST WHEN: #{Time.now.to_s(:db)} IP: #{controller.request.remote_ip} METHOD: #{controller.request.method.to_s.upcase} CONTROLLER: #{controller.controller_class_name} ACTION: #{controller.action_name} AUDIT-ID: #{controller.session[:audit_id]} PARAMS: #{controller.respond_to?(:filter_parameters) ? controller.send(:filter_parameters,controller.params).inspect : controller.params.inspect}})
  end
  
  
  def before_saved(model)
    info(%Q{MODEL: #{model.class} ID: #{model.new_record? ? "new_record" : model.id} CHANGES: #{model.changes.inspect}})
  end
  
  def created(model)
    add_audit("CREATED", model)
  end
  
  def updated(model)
    add_audit("UPDATED", model)
  end
  
  def destroyed(model)
    add_audit("DESTROYED", model)
  end

  def end_audit
    info(%Q{REQUEST ENDED}) 
    flush
  end
  
  private
  def add_audit(status, model)
      info(%Q{#{status}: #{model.class} ID: #{model.id} ATTRIBUTES: #{model.attributes.inspect}})
  end
  
end
