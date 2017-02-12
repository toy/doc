module Doc
  class Configurator
    class Ruby
      class PathInfo < Struct.new(:path, :name, :type, :full_version, :parts)
        private_class_method :new
        def self.latest_matching(version, paths)
          paths.map(&method(:for_path)).compact.grep(version).sort.last
        end

        def self.for_path(path)
          name = path.basename.to_s
          if name =~ /^ruby-(\d+\.\d+\.\d+(?:-p\d+)?)(?i:\.(tar\.(?:gz|bz2)|tgz|tbz|zip))?$/
            extension = $2 ? $2.downcase : :dir
            type = ({'tar.bz2' => 'tbz', 'tar.gz' => 'tgz'}[extension] || extension).to_sym
            new(path, name, type, $1, $1.scan(/\d+/).map(&:to_i))
          end
        end

        def type_priority
          @type_priority ||= {:zip => 0, :tgz => 1, :tbz => 2, :dir => 3}[type]
        end

        def sort_by
          @sort_by ||= [parts, type_priority]
        end

        include Comparable
        def <=>(other)
          sort_by <=> other.sort_by
        end

        def ===(other)
          parts === other.parts
        end
      end
    end
  end
end
