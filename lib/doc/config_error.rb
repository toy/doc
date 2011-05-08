module Doc
  class ConfigError < Exception
    def initialize(object, message)
      super("#{object.class.name}: #{message}").tap do |e|
        if Exception === message
          e.set_backtrace(message.backtrace)
        end
      end
    end
  end
end
