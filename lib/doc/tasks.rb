require 'doc'

module Doc
  class Tasks
    include Rake::DSL

    attr_reader :documentor
    def initialize(*arguments, &block)
      @documentor = Documentor.new(*arguments, &block)
      define
    end

    def humanize_time(seconds)
      case seconds
      when 0...60
        '%.1fs' % seconds
      when 60...3600
        '%.1fm' % (seconds / 60)
      else
        '%.1fh' % (seconds / 3600)
      end
    end

    def count_time
      start = Time.now
      yield
      puts "It took #{humanize_time(Time.now - start)}"
    end

  private

    def define
      task :default => :build

      task :config do
        count_time{ documentor.config }
      end

      desc 'build documentation'
      task :build do
        count_time{ documentor.build }
      end

      namespace :build do
        desc 'force update and build documentation'
        task :update do
          count_time{ documentor.build(true) }
        end
      end
    end
  end
end
