class <%= request_class_name %> < ActiveRecord::Base
  belongs_to :session, :class_name => "<%= session_class_name %>"
  has_many :changes, :class_name => "<%= change_class_name %>"
end
