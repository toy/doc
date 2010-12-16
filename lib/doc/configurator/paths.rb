require 'digest'

module Doc
  class Configurator
    class Paths < Configurator
      default_config_key :glob

      def configure(update)
        check_config_options([:glob, :main, :file_list, :title])

        @path_pairs = []
        Array(config[:glob]).map do |glob|
          if glob[0, 1] == '~' && (parts = glob.split(File::SEPARATOR, 2)).length == 2
            FSPath(glob).expand_path.glob.map do |path|
              unexpanded_part = FSPath(parts[0])
              @path_pairs << [path, unexpanded_part / path.relative_path_from(unexpanded_part.expand_path)]
            end
          else
            @path_pairs.concat(FSPath(glob).glob)
          end
        end.flatten

        if @path_pairs.empty?
          raise ConfiguratorError.new(self, "expanding #{config[:glob].join(', ')} gave empty list")
        end

        @main = Array(config[:main])

        if config[:file_list]
          @file_list = config[:file_list]
          case @file_list
          when Proc
            if @file_list.arity != 1
              raise ConfiguratorError.new(self, "proc should have on parameter for instance of FileList")
            end
          when Array
            unless @file_list.all?{ |rule| rule =~ /^\+|-/ }
              raise ConfiguratorError.new(self, "all rules must start with + or -")
            end
          else
            raise ConfiguratorError.new(self, "file_list should be either array in form %w[+a/* -b/*] or proc receiving instance of FileList")
          end
        end

        if @title = config[:title]
          unless @title.is_a?(Proc) && @title.arity == 1
            raise ConfiguratorError.new(self, "title should be an instance of Proc receiving one argument (path)")
          end
        end
      end

      def tasks
        @path_pairs.map do |pair|
          path, unexpanded_path = pair
          unexpanded_path ||= path
          Dir.chdir(path) do
            paths = nil
            if @file_list
              file_list = FileList.new
              case @file_list
              when Proc
                @file_list.call(file_list)
              when Array
                @file_list.each do |rule|
                  file_list.send(rule[0, 1] == '+' ? :include : :exclude, rule[1..-1])
                end
              end
            end

            main = nil
            if @main
              @main.each do |main|
                break if main = Dir[main].first
              end
            end

            builder({
              :title => @title ? @title[unexpanded_path].to_s : "path #{unexpanded_path}",
              :source_dir => path,
              :dir_name => "path.#{unexpanded_path.to_s.gsub('_', '').gsub('/', '_').gsub(/[^a-z0-9\-_]/i, '-')}.#{Digest::SHA1.hexdigest(path.to_s)}",
              :paths => file_list,
              :main => main,
            })
          end
        end
      end
    end
    RootConfig.send(:alias_method, :path, :paths)
  end
end
