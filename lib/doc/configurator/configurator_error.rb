module Doc
  class Configurator
    class ConfiguratorError < Exception
      def initialize(object, message)
        super("#{object.class.name}\##{object.config.inspect}: #{message}").tap do |e|
          if Exception === message
            e.set_backtrace(message.backtrace)
          end
        end
      end
    end
  end
end
