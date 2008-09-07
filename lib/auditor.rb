class Auditor < ActiveRecord::Observer
  observe TraceableRequest
  def before_save(model)
    DEFAULT_AUDIT_LOG.before_saved(model)
  end
  
  def after_create(model)
    DEFAULT_AUDIT_LOG.created(model)
  end
  
  def after_update(model)
    DEFAULT_AUDIT_LOG.updated(model)
  end
  
  def after_destroy(model)
    DEFAULT_AUDIT_LOG.destroyed(model)
  end
  
end
