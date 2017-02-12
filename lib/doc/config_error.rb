module Doc
  class ConfigError < Exception
    def initialize(object, message)
      super("#{object.class.name}: #{message}")
    end
  end
end
