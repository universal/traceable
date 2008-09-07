class <%= change_class_name %> < ActiveRecord::Base
  belongs_to :request, :class_name => "<%= request_class_name %>"
end
