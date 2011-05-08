module Doc
  class Configurator
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

    def builder(options)
      Builder.new(documentor, options)
    end

    def merger(options)
      Merger.new(documentor, options)
    end
  end
end
