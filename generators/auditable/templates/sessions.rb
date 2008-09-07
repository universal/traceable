class <%= session_class_name %> < ActiveRecord::Base
  has_many :requests, :class_name => "<%= request_class_name %>"
  has_one :start, :class_name => "<%= request_class_name %>", :order => "when ASC"
  has_one :last, :class_name => "<%= request_class_name %>", :order => "when DESC"
end
