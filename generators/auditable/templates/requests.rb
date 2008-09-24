class <%= request_class_name %> < ActiveRecord::Base
  belongs_to :session, :class_name => "<%= session_class_name %>", :foreign_key => "<%= session_singular_name %>_id"
  has_many :modifications, :class_name => "<%= modification_class_name %>"

  def self.search(query, options={})
    with_scope :find => {:conditions => search_conditions(query)} do
      find :all, options   
    end
  end
  
  private
  def self.search_conditions(query)
    return nil if query.blank?
    fields = query.scan(/(\w+): ([\w\.]+)/).select{|option| column_names.include? option[0]}
    time = query.scan(/(start|end): ([\d-]*\s{0,1}[\d:]*)/)
    binds = {}
    and_frags = []
    count = 1
    fields.each do |field, value|
      and_frags << "LOWER(#{field}) LIKE :word#{count}"
      binds["word#{count}".to_sym] = "%#{value.to_s.downcase}%"
      count += 1
    end
    time.each do |field, value|
      begin 
        time_point = Time.parse(value)
      rescue ArgumentError
      end
      if time_point
        case field
          when "start"
            and_frags << "`when` > :word#{count}"
          else
            and_frags << "`when` < :word#{count}"
        end
        binds["word#{count}".to_sym] = time_point
        count += 1
      end      
    end
    [and_frags.join(" AND "), binds]
  end
end
