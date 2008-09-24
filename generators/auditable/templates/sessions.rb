class <%= session_class_name %> < ActiveRecord::Base
  has_many :requests, :class_name => "<%= request_class_name %>"
  has_one :start, :class_name => "<%= request_class_name %>", :order => "when ASC"
  has_one :last, :class_name => "<%= request_class_name %>", :order => "when DESC"

  def self.search(query, options={})
    with_scope :find => {:conditions => search_conditions(query)} do
      find :all, options   
    end
  end
  
  private
#AuditableSession.find(:first, :conditions => ["method = 'POST'"], :joins => :requests)  
  def self.search_conditions(query)
    return nil if query.blank?
    login = query.scan(/login: (\w+)/).flatten[0]
    if login
      return ["LOWER(login) LIKE ?", "%#{login}%"]
    else
      return nil
    end
  end  
end
