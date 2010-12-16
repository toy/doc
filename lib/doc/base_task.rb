require 'digest/sha2'

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
        doc_dir.rmtree_verbose if doc_dir.exist?
        build
        write_config_state
        @state = control_files_exist? ? :succeeded : :failed
      end
    rescue SystemExit
      @state = :failed
    end

    def succeeded?
      @state == :succeeded
    end

    def failed?
      @state == :failed
    end
  end
end
