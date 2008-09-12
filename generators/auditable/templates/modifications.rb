class <%= modification_class_name %> < ActiveRecord::Base
  belongs_to :request, :class_name => "<%= request_class_name %>", :foreign_key => "<%= request_singular_name %>_id"
end
