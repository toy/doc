require 'digest/sha2'
require 'shellwords'
require 'sdoc'

module Doc
  class BaseTask
    attr_reader :documentor, :title, :dir_name, :config
    def initialize(documentor, options)
      @documentor = documentor
      @title = options[:title].to_s
      @dir_name = options[:dir_name].to_s
      doc_dir.touch if doc_dir.exist?
    end

    def doc_dir
      documentor.docs_dir / dir_name
    end

    def self.state_methods(name, data_code_for_state)
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}_state
          @#{name}_state ||= #{data_code_for_state}
        end
        def #{name}_state_path
          doc_dir / '.#{name}_state'
        end
        def #{name}_state_changed?
          !#{name}_state_path.exist? || Marshal.load(#{name}_state_path.read) != #{name}_state
        rescue true
        end
        def write_#{name}_state
          #{name}_state_path.write(Marshal.dump(#{name}_state))
        end
      RUBY
    end

    state_methods :config, <<-RUBY
      @config
    RUBY

    def hash
      config.hash
    end
    def eql?(other)
      config.eql?(other.config)
    end

    def control_files_exist?
      %w[created.rid index.html].all? do |name|
        (doc_dir / name).exist?
      end
    end

    def run?
      config_state_changed? || !control_files_exist?
    end

    abstract_method :build
    def run(force = false)
      if force || run?
        if doc_dir.exist?
          in_progress_message %W[rm -r #{doc_dir}].shelljoin
          doc_dir.rmtree
        end
        build
        write_config_state
        @state = control_files_exist? ? :succeeded : :failed
      end
    rescue SystemExit
      @state = :failed
    end

    def symlink_to(path)
      (path / doc_dir.basename).make_symlink(doc_dir.relative_path_from(path))
    end

    def succeeded?
      @state == :succeeded
    end

    def failed?
      @state == :failed
    end

    def loaded_gem_version(gem)
      Gem.loaded_specs[gem].version
    end

    def in_progress_message(message)
      if Progress.running?
        Progress.note = message
      else
        $stderr.puts message
      end
    end
  end
end
