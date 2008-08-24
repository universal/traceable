module Traceable 
  class Parser
    attr_accessor :file_name, :handler, :log_lines
    
    def initialize(file_name, handler) 
      @file_name = file_name
      @handler = handler
      @log_lines = handler.log_lines
    end
    
    def parse
      File.open(file_name, "r") do |f|
        f.each_line do |line|
          parse_line(line)
        end
      end
    end
    
    def parse_line(line)
      @log_lines.each do |type, options|
        if options[:teaser] =~ line
            if options[:regexp] =~ line
              handler.send type, line, options, $~
              return;
            else
              # not so good...
              handler.send :teased_line, type, line, options
            end
        end
      end
      handler.send :unknown_line, line
    end
  end
end
