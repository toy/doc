module Doc
  class RootConfig < ConfigObject
    attr_reader :documentor
    def initialize(documentor, *arguments, &block)
      @documentor = documentor
      super :title, *arguments, &block

      if clean_after
        if !clean_after.is_a?(Numeric)
          raise "clean_after must be a number, got #{clean_after.inspect}"
        elsif clean_after < 0
          raise "clean_after must zero or greater, got #{clean_after.inspect}"
        end
      end
    end

    def configurators
      @configurators ||= []
    end

    def self.configurator(name, klass)
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(*arguments, &block)
          configurators << #{klass}.new(documentor, *arguments, &block)
        end
      RUBY
    end
  end
end
