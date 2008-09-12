class <%= request_class_name %> < ActiveRecord::Base
  belongs_to :session, :class_name => "<%= session_class_name %>", :foreign_key => "<%= session_singular_name %>_id"
  has_many :modifications, :class_name => "<%= modification_class_name %>"
end
