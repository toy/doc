module Doc
  class Configurator
    class Gems < Configurator
      default_config_key :only

      def configure(update)
        config.check_options!([], [[:only, :except], :versions, :prerelease])

        [:only, :except].each do |key|
          config[key] = Array(config[key]).flatten.map(&:to_s) if config[key]
        end

        @prerelease = !!config[:prerelease]
        @specs = config[:versions] && config[:versions].to_sym == :all ? all_specs(@prerelease) : latest_specs(@prerelease)

        if config[:only]
          absent = config[:only] - @specs.map(&:name)
          unless absent.empty?
            raise ConfigError.new(self, "can't find gems: #{absent.join(', ')}")
          end
        end

        if config[:only]
          @specs = @specs.select{ |spec| config[:only].include?(spec.name) }
        elsif config[:except]
          @specs = @specs.reject{ |spec| config[:except].include?(spec.name) }
        end
        @specs = @specs.sort_by{ |spec| [spec.name.downcase, spec.sort_obj] }
      end

      def tasks
        @specs.map do |spec|
          main = spec.rdoc_options.each_cons(2).select{ |key, value| %w[--main -m].include?(key) }.map(&:last).first
          next if spec.respond_to?(:default_gem?) && spec.default_gem?
          Dir.chdir(spec.full_gem_path) do
            file_list = FileList.new
            file_list.include *spec.extra_rdoc_files
            file_list.include *spec.require_paths

            builder({
              :title => "gem #{spec.full_name}",
              :source_dir => spec.full_gem_path,
              :dir_name => "gem.#{spec.full_name}",
              :paths => file_list,
              :main => main,
            })
          end
        end.compact
      end

    private

      def latest_specs(prerelease)
        Gem::Specification.latest_specs(prerelease)
      end

      def all_specs(prerelease)
        if prerelease
          Gem::Specification.to_a
        else
          Gem::Specification.select{ |spec| !spec.version.prerelease? }
        end
      end

      def sort_specs(specs)
        specs.sort_by{ |spec| [spec.name.downcase, spec.name, spec.version] }
      end
    end
    RootConfig.send(:alias_method, :gem, :gems)
  end
end
