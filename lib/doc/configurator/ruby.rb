module Doc
  class Configurator
    class Ruby < Doc::Configurator
      smart_autoload :PathInfo, :VersionSpecifier, :Source, :Stdlib
      include Source, Stdlib

      default_config_key :binary

      def configure(update)
        check_config_options([[:source, :archive, :version, :binary], :format, :except, :index])

        @source_dirs = case
        when config[:source]
          Array(config[:source]).map{ |source| from_dir(source) }
        when config[:archive]
          Array(config[:archive]).map{ |archive| from_archive(archive) }
        when config[:version]
          Array(config[:version]).map{ |version| by_version(version, update) }
        else
          Array(config[:binary]).map{ |binary| by_binary(binary, update) }
        end

        @format = (config[:format] || :all).to_sym
        unless avaliable_formats.include?(@format)
          raise "format can be one of: #{avaliable_formats.join(', ')}"
        end
        if [:separate, :integrate].include?(@format)
          @stdlib_config = stdlib_config(update) or raise 'can\'t get stdlib config'
        end

        @except_regexp = /^(?:lib|ext)\/(?:#{Array(config[:except]).map(&Regexp.method(:escape)).join('|')})(?:.rb$|\/)/

        if config[:index]
          @index = FSPath(config[:index])
          unless @index.directory? && (@index / 'index.html').file?
            raise 'index should be a path to directory with index.html inside'
          end
        end
      rescue => e
        raise ConfiguratorError.new(self, e)
      end

      def avaliable_formats
        @avaliable_formats ||= methods.map{ |m| m[/^tasks_(.*)$/, 1] }.compact.map(&:to_sym)
      end

      def tasks
        @source_dirs.map do |source_dir|
          source_dir.touch
          Dir.chdir(source_dir) do
            send("tasks_#@format", source_dir)
          end
        end
      end

      def tasks_all(source_dir)
        file_list = FileList.new
        file_list.include(*%w[NEWS LEGAL COPYING GPL LGPL])
        file_list.include("*.#{PARSABLE_EXTENSIONS_GLOB}")
        file_list.include("{lib,ext}/**/*.#{PARSABLE_EXTENSIONS_GLOB}")
        file_list.exclude @except_regexp

        builder({
          :title => source_dir.basename.to_s,
          :source_dir => source_dir,
          :dir_name => source_dir.basename.to_s,
          :paths => file_list,
          :index => @index,
        })
      end

      def tasks_separate(source_dir)
        tasks = []

        core_paths_a = core_paths.to_a

        file_list = FileList.new
        file_list.add(*core_paths_a)
        file_list.exclude @except_regexp

        tasks << builder({
          :title => "#{source_dir.basename} core",
          :source_dir => source_dir,
          :dir_name => "#{source_dir.basename}_core",
          :paths => file_list,
          :index => @index,
        })

        stdlib_tasks = []
        @stdlib_config['targets'].each do |target|
          name = target['target']
          file_list = FileList.new
          file_list.add(*stdlib_paths_for_target(name) - core_paths_a)
          file_list.exclude @except_regexp

          unless file_list.empty?
            stdlib_tasks << builder({
              :title => name,
              :source_dir => source_dir,
              :dir_name => "#{source_dir.basename}_#{name.gsub(/[^a-z0-9\-_]/i, '-')}",
              :paths => file_list,
              :main => target['mainpage'],
              :no_auto_add_paths => true,
            })
          end
        end

        tasks << merger({
          :title => "#{source_dir.basename} stdlib",
          :dir_name => "#{source_dir.basename}_stdlib",
          :tasks => stdlib_tasks
        })

        tasks
      end

      def tasks_integrate(source_dir)
        file_list = FileList.new
        file_list.add(core_paths)
        @stdlib_config['targets'].each do |target|
          file_list.add(stdlib_paths_for_target(target['target']))
        end
        file_list.exclude @except_regexp
        builder({
          :title => "#{source_dir.basename} +stdlib",
          :source_dir => source_dir,
          :dir_name => "#{source_dir.basename}_with_stdlib",
          :paths => file_list,
          :index => @index,
        })
      end

    private

      def core_paths(dir = nil)
        file_list = []

        dot_document_path = FSPath('.document')
        dot_document_path = dir / dot_document_path if dir

        if dot_document_path.exist?
          dot_document_path.readlines.map(&:strip).reject{ |line| line.empty? || line[0] == ?# }
        else
          ['*']
        end.each do |glob|
          FSPath.glob(dir ? dir / glob : glob) do |path|
            if path.directory?
              file_list.concat(core_paths(path))
            else
              file_list << path.to_s
            end
          end
        end

        file_list
      end

      def stdlib_paths_for_target(name)
        file_list = FileList.new
        file_list.include("{lib,ext}/#{name}{,/**/*}.#{PARSABLE_EXTENSIONS_GLOB}")
        file_list.include("{lib,ext}/#{name}/**/README*")
        file_list.exclude(%r{/extconf.rb$|/test/(?!unit)|/tests/|/sample|/demo/})
        file_list.to_a
      end
    end
  end
end
