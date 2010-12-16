module Doc
  class ConfigObject
    def initialize(default_key, *arguments, &block)
      @hash = {}
      arguments = arguments.dup
      if arguments.last.is_a?(Hash)
        @hash.merge!(arguments.pop)
      end
      unless arguments.empty?
        @hash[default_key] = arguments
      end

      block.call(self) if block
    end

    def [](key)
      @hash[key]
    end

    def []=(key, value)
      @hash[key] = value
    end

    def keys
      @hash.keys
    end

    def method_missing(method, *arguments)
      case method.to_s
      when /\!$/
        check_argument_count arguments, 0
        @hash[$`.to_sym] = true
      when /\?$/
        check_argument_count arguments, 0
        @hash[$`.to_sym] && true
      else
        if arguments.empty?
          @hash[method]
        else
          check_argument_count arguments, 1
          @hash[method] = arguments.first
        end
      end
    end

  private

    def check_argument_count(arguments, accepts)
      if arguments.length != accepts
        raise ArgumentError.new("wrong number of arguments (#{arguments.length} for #{accepts})")
      end
    end
  end
end
