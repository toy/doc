require 'shellwords'

module Doc
  class Configurator
    class Rails < Configurator
      default_config_key :version

      def configure(update)
        config.check_options!([], [:version, :prerelease])

        search_versions = Array(config[:version] || [nil])
        @versions = search_versions.map do |search_version|
          dependency = Gem::Dependency.new('rails', search_version.is_a?(Integer) ? "~> #{search_version}" : search_version)
          versions = Gem.source_index.search(dependency).map(&:version)
          versions.reject!(&:prerelease?) unless config[:prerelease]
          unless version = versions.sort.last
            raise ConfigError.new(self, "can't find rails version matching: #{search_version}")
          end
          version
        end
      end

      def tasks
        @versions.map do |version|
          builder({
            :title => "rails-#{version}",
            :dir_name => "rails-#{version}",
            :paths => paths_to_document_for_version(version),
          })
        end
      end

    private

      def version_less_than_3?(version)
        version.segments.first < 3
      end

      def paths_to_document_for_version(version)
        code = if version_less_than_3?(version)
          <<-RUBY
            require 'rake/rdoctask'
            gem 'rails', ARGV.first

            Rake::FileList.class_eval do
              alias_method :original_include, :include
              def include(*paths, &block)
                original_include(*fix_paths(*paths), &block)
              end

              alias_method :original_exclude, :exclude
              def exclude(*paths, &block)
                original_exclude(*fix_paths(*paths), &block)
              end

              def fix_paths(*paths)
                paths.map do |path|
                  if path.is_a?(String)
                    path.sub(%r{^vendor\/rails\/([^\/]+)(?=\/)}) do
                      name = {'railties' => 'rails'}[$1] || $1
                      Gem.loaded_specs[name].full_gem_path
                    end
                  else
                    path
                  end
                end
              end
            end

            Rake::RDocTask.class_eval do
              def define
                puts rdoc_files if name == 'rails'
              end
            end

            load 'tasks/documentation.rake'
          RUBY
        else
          <<-RUBY
            require 'rake/rdoctask'
            gem 'rails', ARGV.first

            class RDocTaskWithoutDescriptions < Rake::RDocTask
              def initialize(name = :rdoc)
                super
                puts rdoc_files if name == 'rails'
              end
            end

            load 'rails/tasks/documentation.rake'
          RUBY
        end
        args = %W[ruby -r rubygems -e #{code} -- #{version}]
        IO.popen(args.shelljoin, &:readlines).map(&:strip)
      end
    end
  end
end
