class AuditLog < ActiveSupport::BufferedLogger
  def audit(controller)
    RAILS_DEFAULT_LOGGER.debug "current_user: #{controller.send :current_user}"
    flush
    info(%Q{REQUEST WHEN: #{Time.now.to_s(:db)} IP: #{controller.request.remote_ip} METHOD: #{controller.request.method.to_s.upcase} CONTROLLER: #{controller.controller_class_name} ACTION: #{controller.action_name} SESSION-ID: #{controller.session.session_id.gsub(/\015?\012/, '')} PARAMS: #{controller.respond_to?(:filter_parameters) ? controller.filter_parameters(controller.params).inspect : controller.params.inspect}})
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
