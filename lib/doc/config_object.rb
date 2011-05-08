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

    def check_options!(required_keys, optional_keys)
      errors = []

      unless (missing_keys = required_keys - keys).empty?
        errors << "missing required keys: #{missing_keys.join(', ')}"
      end

      left_keys = keys - required_keys
      optional_keys.each do |key_group|
        key_group = Array(key_group)
        if key_group.length > 1
          if (clashing_keys = keys & key_group).length > 1
            errors << "clash of mutually exclusive keys: #{clashing_keys.join(', ')}"
          end
        end
        left_keys -= key_group
      end
      unless left_keys.empty?
        errors << "unknown keys: #{left_keys.join(', ')}"
      end

      unless errors.empty?
        raise ConfigError.new(self, errors.join('; '))
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
