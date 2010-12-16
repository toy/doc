module Doc
  class Configurator
    smart_autoload :ConfiguratorError

    class << self
      def inherited(subclass)
        RootConfig.configurator subclass.name.underscore.split('/').last, subclass
      end

      def default_config_key(value = nil)
        @default_config_key = value.to_sym if value
        @default_config_key || :default
      end
    end

    attr_reader :documentor, :config
    def initialize(documentor, *arguments, &block)
      @documentor = documentor
      @config = ConfigObject.new(self.class.default_config_key, *arguments, &block)
    end

    abstract_method :configure, :tasks

  private

    PARSABLE_EXTENSIONS_GLOB = "{#{%w[rb  c m C M cc CC mm MM c++ cxx cpp  h H hh HH hm h++ hpp hxx  y].join(',')}}"

    def sources_dir
      documentor.sources_dir.tap(&:mkpath)
    end

    def check_config_options(optional_keys, required_keys = [])
      errors = []

      unless (missing_keys = required_keys - config.keys).empty?
        errors << "missing required keys: #{missing_keys.join(', ')}"
      end

      left_keys = config.keys - required_keys
      optional_keys.each do |keys|
        keys = Array(keys)
        if keys.length > 1
          if (clashing_keys = config.keys & keys).length > 1
            errors << "clash of mutually exclusive keys: #{clashing_keys.join(', ')}"
          end
        end
        left_keys -= keys
      end
      unless left_keys.empty?
        errors << "unknown keys: #{left_keys.join(', ')}"
      end

      unless errors.empty?
        raise ConfiguratorError.new(self, errors.join('; '))
      end
    end

    def builder(options)
      Builder.new(documentor, options)
    end

    def merger(options)
      Merger.new(documentor, options)
    end
  end
end
