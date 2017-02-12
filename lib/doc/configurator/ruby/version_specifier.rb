module Doc
  class Configurator
    class Ruby
      class VersionSpecifier
        attr_reader :str, :parts
        alias_method :to_s, :str
        def initialize(o)
          @str = o.to_s
          @parts = str.scan(/\d+/).map(&:to_i)
        end

        def drop
          self.class.new(parts.drop(1).join('.'))
        end

        def valid?
          str =~ /^\d+\.\d+(?:\.\d+(?:-p\d+)?)?$/
        end

        def full_version?
          valid? && parts.length == 4
        end

        def dir_name
          fmt = 'ruby' + %w[-%d .%d .%d -p%d].take(parts.length).join('')
          fmt % parts
        end

        include Comparable
        def <=>(other)
          parts <=> other.parts
        end

        def ===(other)
          if other.respond_to?(:parts)
            parts == other.parts[0, parts.length]
          else
            str === other
          end
        end
      end
    end
  end
end
